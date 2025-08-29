terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.3"
}

provider "aws" {
  region = var.aws_region
}

# ECS Task Role (assumed by your container)
resource "aws_iam_role" "ecs_task" {
  name = "${var.app_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# ECS Task Execution Role (pulls images from ECR, writes logs, fetches SSM secrets)
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# Attach standard managed policy (ECR read + CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allow execution role to read the Rails master key from SSM and decrypt with KMS
resource "aws_iam_role_policy" "ecs_exec_ssm_kms" {
  name = "${var.app_name}-exec-ssm-kms"
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ReadRailsMasterKey",
        Effect   = "Allow",
        Action   = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParameterHistory"
        ],
        Resource = var.rails_master_key_arn
      },
      {
        Sid      = "DecryptForSSMParameter",
        Effect   = "Allow",
        Action   = ["kms:Decrypt"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Create the ECR repository for this app (idempotent)
resource "aws_ecr_repository" "captcha_demo" {
  name                 = "app47/captcha-demo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_security_group" "alb" {
  name        = "captcha-demo-alb-sg"
  description = "Allow inbound HTTPS from the world"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_service" {
  name        = "captcha-demo-svc-sg"
  description = "Allow inbound from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "captcha_demo" {
  name               = "captcha-demo-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.alb_subnet_ids
}

resource "aws_lb_target_group" "captcha_demo" {
  name        = "captcha-demo-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health_check"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.captcha_demo.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.captcha_demo.arn
  }
}

resource "aws_ecs_cluster" "captcha_demo" {
  name = "captcha-demo-cluster"
}

# Manage the log group explicitly (matches your task's logConfiguration)
resource "aws_cloudwatch_log_group" "captcha_demo" {
  name              = "/ecs/captcha-demo"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "captcha_demo" {
  family                   = "captcha-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "captcha-demo",
      image     = var.image_url,
      essential = true,
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ],
      environment = [
        { name = "RAILS_ENV", value = "production" },
        { name = "RACK_ENV", value = "production" },
        { name = "RAILS_LOG_TO_STDOUT", value = "true" },
        { name = "RAILS_SERVE_STATIC_FILES", value = "true" }
      ],
      secrets = [
        {
          name      = "RAILS_MASTER_KEY",
          valueFrom = var.rails_master_key_arn
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/captcha-demo",
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "captcha-demo"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "captcha_demo" {
  name                   = "captcha-demo-service"
  cluster                = aws_ecs_cluster.captcha_demo.id
  task_definition        = aws_ecs_task_definition.captcha_demo.arn
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.captcha_demo.arn
    container_name   = "captcha-demo"
    container_port   = 3000
  }

  desired_count = 1
  depends_on    = [aws_lb_listener.https]
}

# Optional: HTTP listener to redirect to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.captcha_demo.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

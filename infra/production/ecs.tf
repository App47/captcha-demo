
resource "aws_ecs_cluster" "captcha_demo" {
  name = local.cluster_name
}

resource "aws_ecs_task_definition" "captcha_demo" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name,
      image     = var.image_url,
      essential = true,
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ],
      environment = [
        { name = "RAILS_ENV", value = var.env_name },
        { name = "RACK_ENV", value = var.env_name },
        { name = "VERSION_TAG", value = var.version_tag },
        { name = "RAILS_LOG_TO_STDOUT", value = "true" },
        { name = "RAILS_SERVE_STATIC_FILES", value = "true" },
        { name = "NEW_RELIC_LOG", value = "stdout" },
        { name = "NEW_RELIC_LOG_LEVEL", value = "debug" }
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
          awslogs-group         = local.log_group_name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = var.app_name
        }
      }
    }
  ])
}

resource "aws_ecs_service" "captcha_demo" {
  name                   = local.service_name
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
    container_name   = var.app_name
    container_port   = 3000
  }

  desired_count = 1
  depends_on    = [aws_lb_listener.https]
}

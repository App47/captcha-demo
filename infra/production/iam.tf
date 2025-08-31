# Grant the execution role permission to read the Rails master key from SSM
resource "aws_iam_policy" "ecs_exec_read_rails_master_key" {
  name        = "${var.env_name}-ecs-exec-read-rails-master-key"
  description = "Allow ECS task execution role to read Rails master key from SSM Parameter Store"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGetRailsMasterKey",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = var.rails_master_key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach_read_master_key" {
  role       = aws_iam_role.ecs_task_execution.id
  policy_arn = aws_iam_policy.ecs_exec_read_rails_master_key.arn
}


# ECS Task Role (assumed by your container)
resource "aws_iam_role" "ecs_task" {
  name = local.ecs_task_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# ECS Task Execution Role (pulls images from ECR, writes logs, fetches SSM secrets)
resource "aws_iam_role" "ecs_task_execution" {
  name = local.ecs_task_execution

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action    = "sts:AssumeRole"
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
  name = local.ecs_kms_name
  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ReadRailsMasterKey",
        Effect = "Allow",
        Action = [
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
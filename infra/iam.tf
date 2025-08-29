provider "aws" {
  alias  = "target"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::883585999409:role/TerraformAdminRole"
  }
}

# Grant the execution role permission to read the Rails master key from SSM
resource "aws_iam_policy" "ecs_exec_read_rails_master_key" {
  name        = "EcsExecReadRailsMasterKey"
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

# Remove this broad policy; it's not needed for ECS tasks and targets the wrong role.
# resource "aws_iam_role_policy_attachment" "ecs_task_exec_ssm" {
#   role       = aws_iam_role.ecs_task.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }


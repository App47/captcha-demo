provider "aws" {
  alias  = "target"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::883585999409:role/TerraformAdminRole"
  }
}

data "aws_iam_role" "app" {
  provider = aws.target
  name     = var.app_role_name
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_ssm" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

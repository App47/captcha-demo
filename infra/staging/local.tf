locals {
  # captcha-demo-{environment}-{role}. This app has no tenant.
  project     = "captcha-demo"
  name_prefix = "${local.project}-${var.env_name}"

  cluster_name                 = "${local.name_prefix}-cluster"
  service_name                 = "${local.name_prefix}-service"
  task_family                  = "${local.name_prefix}-task"
  container_name               = local.project
  log_group_name               = "/ecs/${local.name_prefix}"
  tg_name                      = "${local.name_prefix}-tg"
  svc_sg_name                  = "${local.name_prefix}-ecs-sg"
  ecs_task_name                = "${local.name_prefix}-task-role"
  ecs_task_execution           = "${local.name_prefix}-execution-role"
  ecs_kms_name                 = "${local.name_prefix}-ssm-kms"
  rails_master_key_policy_name = "${local.name_prefix}-rails-master-key"
}

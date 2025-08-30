locals {
  # Centralize common names so they’re consistent everywhere
  cluster_name       = "${var.app_name}-cluster"
  service_name       = "${var.app_name}-service"
  log_group_name     = "/ecs/${var.app_name}"
  tg_name            = "${var.app_name}-tg"
  alb_name           = "${var.app_name}-alb"
  alb_sg_name        = "${var.app_name}-alb-sg"
  svc_sg_name        = "${var.app_name}-svc-sg"
  ecs_task_name      = "${var.app_name}-task-role"
  ecs_task_execution = "${var.app_name}-execution-role"
  ecs_kms_name       = "${var.app_name}-exec-ssm-kms"
}

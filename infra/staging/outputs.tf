output "cluster_name" { value = local.cluster_name }
output "service_name" { value = local.service_name }
output "alb_dns_name" { value = aws_lb.captcha_demo.dns_name }
output "log_group" { value = local.log_group_name }
output "task_family" { value = aws_ecs_task_definition.captcha_demo.family }
# Target group only (Fargate => target_type=ip)
resource "aws_lb_target_group" "captcha_demo" {
  name        = local.tg_name
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health_check" # per your standard
    protocol            = "HTTP"
    interval            = 40
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
}

# Host-based routing on shared ALB listener
resource "aws_lb_listener_rule" "captcha_demo_host" {
  listener_arn = var.alb_https_listener_arn
  priority     = 45 # choose a unique priority across all rules on the listener

  condition {
    host_header {
      values = [var.fqdn_name]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.captcha_demo.arn
  }
}

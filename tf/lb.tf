resource "aws_lb" "this" {
  name               = local.base_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.this.ids
  security_groups    = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "this" {
  name        = local.base_name
  vpc_id      = local.vpc_id
  protocol    = "HTTP"
  port        = local.container_port
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/health"
    port                = "traffic-port"
    matcher             = 200
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "https" {
  count = var.app.protocol == "HTTPS" ? 1 : 0

  load_balancer_arn = aws_lb.this.id
  port              = var.app.port
  protocol          = var.app.protocol
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.id
  }
}

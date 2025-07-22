# Network Load Balancer
resource "aws_lb" "app_nlb" {
  name               = "${var.env}-AWS-pipeline-nlb"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [var.security_group_id]
  subnets            = var.public_subnet_ids

  tags = var.tags
  depends_on = [ aws_autoscaling_group.app_asg ]
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.env}-AWS-pipeline-tg"
  port     = 8002
  protocol = "TCP"
  vpc_id   = var.vpc_id
  tags = var.tags
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 6
    interval            = 10
    port                = "traffic-port"
    protocol            = "TCP"
  }
  deregistration_delay = 30
}

# ALB Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_nlb.arn
  port              = "8002"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
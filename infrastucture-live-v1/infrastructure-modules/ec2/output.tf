output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

output "tg_name" {
  description = "name of the target group"
  value       = aws_lb_target_group.app_tg.name
}
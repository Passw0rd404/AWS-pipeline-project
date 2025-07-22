resource "aws_codedeploy_app" "main" {
  name             = "${var.env}-deploy"
  compute_platform = "Server"

  tags = {
    Name        = "${var.env}-deploy"
    Environment = var.env
  }
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "${var.env}-deploy-group"
  service_role_arn      = aws_iam_role.codedeploy_service_role.arn

  # Deployment configuration
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # Auto Scaling Groups configuration
  autoscaling_groups = [
    var.auto_scaling_group_name
    ]

  # Termination hook configuration
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # in-place deployment configuration
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }


  # Load balancer configuration (disabled)
  #load_balancer_info {
  #  target_group_info {
  #    name = var.tg_name
  #  }
  #}

  tags = {
    Name        = "${var.env}-srv02-deploy-group"
    Environment = var.env
  }
}
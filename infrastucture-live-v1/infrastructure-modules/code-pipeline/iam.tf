  # CodeDeploy Service Role for EC2/On-premises deployments
  resource "aws_iam_role" "codedeploy_service_role" {
    name = "${var.env}-codedeploy-service-role"
    
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codedeploy.amazonaws.com"
          }
        }
      ]
    })

    tags = {
      Environment = var.env
      Service     = "CodeDeploy"
      ManagedBy   = "Terraform"
    }
  }

  # Use the EC2-specific managed policy for CodeDeploy
  resource "aws_iam_role_policy_attachment" "codedeploy_service_ec2" {
    role       = aws_iam_role.codedeploy_service_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  }

  # Additional permissions for Auto Scaling integration
  resource "aws_iam_role_policy" "codedeploy_asg_policy" {
    name = "${var.env}-codedeploy-asg-policy"
    role = aws_iam_role.codedeploy_service_role.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AutoScalingAccess"
          Effect = "Allow"
          Action = [
            "autoscaling:CompleteLifecycleAction",
            "autoscaling:DeleteLifecycleHook",
            "autoscaling:DescribeLifecycleHooks",
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:PutLifecycleHook",
            "autoscaling:RecordLifecycleActionHeartbeat"
          ]
          Resource = "*"
        },
        {
          Sid    = "LoadBalancerAccess"
          Effect = "Allow"
          Action = [
            "elasticloadbalancing:DescribeTargetGroups",
            "elasticloadbalancing:DescribeTargetHealth",
            "elasticloadbalancing:ModifyTargetGroup",
            "elasticloadbalancing:ModifyTargetGroupAttributes",
            "elasticloadbalancing:RegisterTargets",
            "elasticloadbalancing:DeregisterTargets"
          ]
          Resource = "*"
        }
      ]
    })
  }

  # CodeBuild Service Role
  resource "aws_iam_role" "codebuild_role" {
    name = "${var.env}-codebuild-role"
    
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codebuild.amazonaws.com"
          }
        }
      ]
    })

    tags = {
      Environment = var.env
      Service     = "CodeBuild"
      ManagedBy   = "Terraform"
    }
  }

  # CodeBuild policy with restricted permissions
  resource "aws_iam_role_policy" "codebuild_policy" {
    name = "${var.env}-codebuild-policy"
    role = aws_iam_role.codebuild_role.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "CloudWatchLogs"
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = [
            "arn:aws:logs:*:*:log-group:/aws/codebuild/${var.env}*"
          ]
        },
        {
          Sid    = "S3ArtifactsAccess"
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:PutObject"
          ]
          Resource = [
            "${aws_s3_bucket.artifacts.arn}/*"
          ]
        },
        {
          Sid    = "S3ArtifactsBucket"
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:GetBucketVersioning"
          ]
          Resource = aws_s3_bucket.artifacts.arn
        },
        {
          Sid    = "SSMParameterAccess"
          Effect = "Allow"
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:GetParametersByPath"
          ]
          Resource = [
            "arn:aws:ssm:*:*:parameter/${var.env}/*"
          ]
        }
      ]
    })
  }

  # CodePipeline Service Role
  resource "aws_iam_role" "codepipeline_role" {
    name = "${var.env}-codepipeline-role"
    
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "codepipeline.amazonaws.com"
          }
        }
      ]
    })

    tags = {
      Environment = var.env
      Service     = "CodePipeline"
    }
  }

  # CodePipeline policy for GitHub source and EC2 deployment
  resource "aws_iam_role_policy" "codepipeline_policy" {
    name = "${var.env}-codepipeline-policy"
    role = aws_iam_role.codepipeline_role.id

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "S3ArtifactsAccess"
          Effect = "Allow"
          Action = [
            "s3:GetBucketVersioning",
            "s3:GetObject",
            "s3:GetObjectVersion",
            "s3:PutObject"
          ]
          Resource = [
            aws_s3_bucket.artifacts.arn,
            "${aws_s3_bucket.artifacts.arn}/*"
          ]
        },
        {
          Sid    = "CodeBuildAccess"
          Effect = "Allow"
          Action = [
            "codebuild:BatchGetBuilds",
            "codebuild:StartBuild"
          ]
          Resource = [
            aws_codebuild_project.main.arn
          ]
        },
        {
          Sid    = "CodeDeployAccess"
          Effect = "Allow"
          Action = [
            "codedeploy:CreateDeployment",
            "codedeploy:GetDeployment",
            "codedeploy:GetDeploymentConfig",
            "codedeploy:RegisterApplicationRevision",
            "codedeploy:GetApplication",
            "codedeploy:GetApplicationRevision",
            "codedeploy:ListApplicationRevisions",
            "codedeploy:ListDeploymentGroups"
          ]
          Resource = "*"
        },
        {
          Sid    = "CodeStarConnections"
          Effect = "Allow"
          Action = [
            "codestar-connections:UseConnection",
            "codeconnections:GetConnection",
            "codeconnections:UseConnection"
          ]
          Resource = data.aws_codestarconnections_connection.github.arn
        },
        {
          Sid    = "PassRole"
          Effect = "Allow"
          Action = "iam:PassRole"
          Resource = [
            aws_iam_role.codedeploy_service_role.arn
          ]
          Condition = {
            StringEquals = {
              "iam:PassedToService" = "codedeploy.amazonaws.com"
            }
          }
        }
      ]
    })
  }

resource "aws_s3_bucket" "artifacts" {
  bucket = "aws-big-daddy"

  tags = {
    Name        = "${var.env}-artifacts"
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CodeBuild project
resource "aws_codebuild_project" "main" {
  name         = "${var.env}-build"
  description  = "Build project for ${var.env} environment"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"  # Pipeline integration
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                      = "mcr.microsoft.com/dotnet/sdk:8.0"
    type                       = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.env
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  tags = {
    Name        = "${var.env}-build"
    Environment = var.env
  }
}
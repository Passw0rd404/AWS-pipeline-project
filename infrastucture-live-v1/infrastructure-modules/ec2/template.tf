resource "aws_launch_template" "main" {
  name_prefix   = "${var.env}-AWS-pipeline-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(file("${path.module}/build.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [var.security_group_id]
    device_index               = 0
  }

  tags = {
    Name        = "${var.env}-AWS-pipeline-launch-template"
    Environment = var.env
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

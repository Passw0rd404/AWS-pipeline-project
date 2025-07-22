variable "region" {
    description = "AWS region"
    type = string
    default = "eu-north-1"
}

variable "env" {
    description = "enviroment name"
    type = string
    default = "prod"
}

variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t3.micro"
}

variable "key_name" {
    description = "EC2 Key Pair name"
    type = string
    default = "aws-hero"
}

variable "min_size" {
    type = number
    default = 1
}

variable "max_size" {
    type = number
    default = 3
}

variable "desired_capacity" {
    type = number
    default = 2
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Application   = "ASP-app"
    Environment   = "production"
  }
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the Load Balancer"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the application security group"
  type       = string
}

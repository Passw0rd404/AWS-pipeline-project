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

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}

variable "auto_scaling_group_name" {
  description = "Auto Scaling Group name"
  type        = string
}

#variable "tg_name" {
#  description = "target group name"
#  type        = string
#}
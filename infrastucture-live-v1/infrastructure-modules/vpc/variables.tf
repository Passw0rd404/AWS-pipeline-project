# Variables
variable "vpc" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "pub_1" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "pub_2" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

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


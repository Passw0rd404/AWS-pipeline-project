# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "pub_1_id" {
  description = "Public Subnet 1 ID"
  value       = aws_subnet.pub_1.id
}

output "pub_2_id" {
  description = "Public Subnet 2 ID"
  value       = aws_subnet.pub_2.id
}

output "security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app_sg.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}
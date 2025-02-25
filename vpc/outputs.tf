output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "lb_security_group_id" {
  description = "Security group ID for the load balancer"
  value       = aws_security_group.lb_sg.id
}

# output "vpc_id" {
#   value =  module.vpc.vpc_id                                        # The actual value to be outputted
#   description = "The public IP address of the EC2 instance" # Description of what this output represents
# }

# output "vpc_id" {
#   description = "ID of the VPC"
#   value       = aws_vpc.this.id
# }
#
# output "public_subnets" {
#   description = "List of public subnet IDs"
#   value       = aws_subnet.public[*].id
# }
#
# output "private_subnets" {
#   description = "List of private subnet IDs"
#   value       = aws_subnet.private[*].id
# }
variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "security_groups" {
  description = "List of security group IDs for the load balancer"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the target group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
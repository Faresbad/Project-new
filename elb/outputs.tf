output "lb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}
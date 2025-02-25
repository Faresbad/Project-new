output "parameter_name" {
  description = "Name of the SSM parameter"
  value       = aws_ssm_parameter.this.name
}
variable "parameter_name" {
  description = "Name of the SSM parameter"
  type        = string
}

variable "parameter_value" {
  description = "Value of the SSM parameter"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
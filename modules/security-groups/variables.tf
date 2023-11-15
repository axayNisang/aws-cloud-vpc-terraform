variable "vpc_id" {
  type        = string
  description = "Target VPC ID"
}

variable "environment" {
  type        = string
  description = "Target environment"
}

variable "app_port" {
  type        = number
  description = "Target application listening port"
  default     = 8080
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "environment" {
  type        = string
  description = "Target deployment environment (staging, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Base CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of AWS availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private app subnets"
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
  default     = {}
}

variable "single_nat_gateway" {
  type        = bool
  description = "Provision a single shared NAT gateway for dev/staging cost savings"
  default     = false
}

variable "database_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for isolated DB tier subnets"
  default     = ["10.0.100.0/24", "10.0.200.0/24", "10.0.210.0/24"]
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "prod-terraform-state-enterprise"
    key            = "networking/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EnterprisePlatform"
      ManagedBy   = "Terraform"
      Environment = "Production"
      Owner       = "PlatformEngineering"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment            = "prod"
  vpc_cidr               = "10.0.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs   = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  database_subnet_cidrs  = ["10.0.100.0/24", "10.0.200.0/24", "10.0.210.0/24"]
  single_nat_gateway     = false # Multi-AZ High Availability Redundancy
}

module "security_groups" {
  source = "../../modules/security-groups"

  vpc_id      = module.vpc.vpc_id
  environment = "prod"
  app_port    = 8080
}

module "alb" {
  source = "../../modules/alb"

  environment       = "prod"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  app_port          = 8080
  health_check_path = "/health"
}

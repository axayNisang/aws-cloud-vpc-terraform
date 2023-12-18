# AWS Enterprise Production VPC & Network Topology (Terraform) ☁️

[![Terraform CI](https://github.com/axayNisang/aws-cloud-vpc-terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/axayNisang/aws-cloud-vpc-terraform/actions)
[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4.svg?logo=terraform)](https://www.terraform.io)
[![AWS Provider](https://img.shields.io/badge/AWS-5.0+-FF9900.svg?logo=amazon-aws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A production-grade, highly available multi-AZ network infrastructure as code built for enterprise Kubernetes (EKS) and containerized microservice architectures.

---

## 🏛 Network Architecture

```
                                    Internet
                                       │
                                       ▼ [IGW]
              ┌──────────────────────────────────────────────────┐
              │                   VPC (10.0.0.0/16)              │
              │                                                  │
              │  Availability Zone A   Availability Zone B   AZ C│
              │ ┌──────────────────┐  ┌──────────────────┐  ...  │
              │ │ Public Subnet    │  │ Public Subnet    │       │
              │ │ 10.0.1.0/24      │  │ 10.0.2.0/24      │       │
              │ │ [ALB / NAT GW A] │  │ [ALB / NAT GW B] │       │
              │ └────────┬─────────┘  └────────┬─────────┘       │
              │          │                     │                 │
              │ ┌────────▼─────────┐  ┌────────▼─────────┐       │
              │ │ Private App Tier │  │ Private App Tier │       │
              │ │ 10.0.10.0/24     │  │ 10.0.20.0/24     │       │
              │ │ [ECS/EKS Nodes]  │  │ [ECS/EKS Nodes]  │       │
              │ └────────┬─────────┘  └────────┬─────────┘       │
              │          │                     │                 │
              │ ┌────────▼─────────┐  ┌────────▼─────────┐       │
              │ │ Isolated DB Tier │  │ Isolated DB Tier │       │
              │ │ 10.0.100.0/24    │  │ 10.0.200.0/24    │       │
              │ │ [RDS Multi-AZ]   │  │ [RDS Standby]    │       │
              │ └──────────────────┘  └──────────────────┘       │
              └──────────────────────────────────────────────────┘
```

---

## 🛡 Security & Design Principles

1. **Strict 3-Tier Network Isolation**:
   - **Public Subnets**: Ingress point for Application Load Balancers and outbound NAT Gateways.
   - **Private Application Subnets**: Containers and workloads run here with no direct internet ingress; outbound traffic routes via NAT Gateways.
   - **Isolated Database Subnets**: Zero internet access (no IGW, no NAT route). Inaccessible except on port 5432 directly from authorized Application Security Groups.
2. **High Availability & Fault Tolerance**:
   - Subnets distributed across 3 Availability Zones (`us-east-1a`, `us-east-1b`, `us-east-1c`).
   - Production environment features dedicated NAT Gateways per AZ to avoid single-point failure bottlenecks; staging supports cost-saving single-NAT mode.
3. **Auditability & Observability**:
   - AWS CloudWatch Flow Logs capture all ACCEPT/REJECT traffic across the VPC network interfaces with automated 30-day lifecycle retention.
4. **Least-Privilege Security Group Matrix**:
   - Application tier only allows inbound from ALB security group ID.
   - Database tier only allows inbound from App security group ID.

---

## 📂 Repository Layout

```
├── modules/
│   ├── vpc/                 # Multi-AZ VPC, subnets, route tables, IGW, NAT GW, Flow Logs
│   ├── security-groups/     # Tiered least-privilege security groups (ALB, App, DB)
│   └── alb/                 # Application load balancer and dynamic target groups
├── environments/
│   ├── prod/                # Production environment root workspace (remote S3 backend)
│   └── staging/             # Staging environment root workspace
└── .github/workflows/       # Automated fmt, validate, and tflint CI checks
```

---

## 🚀 Deployment Guide

### Prerequisites
- [Terraform >= 1.5.0](https://www.terraform.io/downloads.html)
- AWS CLI configured with administrator or network IAM credentials

### Initializing and Validating

```bash
# Navigate to the target environment
cd environments/prod

# Initialize Terraform modules and backend
terraform init

# Validate configuration syntax
terraform validate

# Review the execution plan
terraform plan

# Apply infrastructure changes
terraform apply
```

---

## 📄 License
MIT License. Created by [Akshay Nisang](https://github.com/axayNisang).

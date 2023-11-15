resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Public ingress security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP ingress"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound to application tier only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-alb-sg" })
}

resource "aws_security_group" "app" {
  name        = "${var.environment}-app-service-sg"
  description = "Security group for ECS/EKS container services"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from ALB only"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound to NAT gateway / external dependencies"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-app-sg" })
}

resource "aws_security_group" "database" {
  name        = "${var.environment}-database-sg"
  description = "Isolated database security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from App tier only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    description = "Deny all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  tags = merge(var.tags, { Name = "${var.environment}-db-sg" })
}

locals {
  name_prefix = var.db_identifier
}

resource "random_password" "db_password" {
  length           = 16
  override_special = "@#%&*()-_=+[]{}<>?"
  special          = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${local.name_prefix}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${local.name_prefix}-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Allow DB access from application stack"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.allowed_security_group_ids) > 0 ? var.allowed_security_group_ids : var.allowed_cidr_blocks
    content {
      from_port       = 5432
      to_port         = 5432
      protocol        = "tcp"
      cidr_blocks     = length(var.allowed_security_group_ids) > 0 ? [] : [ingress.value]
      security_groups = length(var.allowed_security_group_ids) > 0 ? [ingress.value] : []
      description     = "Allow app access to DB"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier             = local.name_prefix
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = var.multi_az
  apply_immediately      = true
  tags = {
    Name = local.name_prefix
  }
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "${local.name_prefix}-credentials"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.db_name
  })
}


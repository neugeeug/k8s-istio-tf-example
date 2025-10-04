output "db_host" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_identifier" {
  value = aws_db_instance.this.id
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}


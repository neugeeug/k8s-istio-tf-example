variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Existing VPC id where the DB must be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet ids in the existing VPC"
  type        = list(string)
}

variable "db_identifier" {
  type    = string
  default = "feature-app-db"
}

variable "db_engine" {
  type    = string
  default = "postgres"
}

variable "db_engine_version" {
  type    = string
  default = "15"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the DB (e.g., EKS worker or control plane SGs). Can be empty; then use allowed_cidr_blocks."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to DB as fallback"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  type    = bool
  default = false
}


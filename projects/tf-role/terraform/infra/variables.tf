variable "region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
}

variable "name" {
  type    = string
  default = "atlas-rds-pg-guide"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR allowed to connect to the public RDS endpoint."
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "engine_version" {
  type        = string
  default     = null
  description = "Optional PostgreSQL engine version. Null uses the AWS default for the region."
}

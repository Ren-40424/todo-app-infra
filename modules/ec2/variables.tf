variable "project_name" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_address" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "environment" {
  type = string
}

variable "api_project_path" {
  type = string
}

variable "user_pool_id" {
  type = string
}

variable "api_allowed_host" {
  type = string
}

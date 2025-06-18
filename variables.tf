variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "backend_bucket_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    public     = bool
    az_suffix  = string
    usage      = string
  }))
  description = "キーはサブネット名、az_suffixはAZ指定、usageはタグやフィルタ条件に使用されます。"
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "alb_health_check_path" {
  type    = string
  default = "/"
}

variable "alb_health_check_matcher" {
  type    = string
  default = "200"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_username" {
  type = string
}

variable "db_name" {
  type = string
}

variable "app_default_root_object" {
  type = string
}

variable "app_bucket_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "route53_zone_id" {
  type = string
}
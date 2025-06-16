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
  description = "キーはサブネット名、az_suffixはAZ指定、usageはタグに使用されます。"
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

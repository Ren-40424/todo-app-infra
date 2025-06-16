variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block = string
    public     = bool
    az_suffix  = string
    usage      = string
  }))
}

variable "igw_id" {
  type = string
}
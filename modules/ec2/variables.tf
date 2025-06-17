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

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "health_check_path" {
  type    = string
  default = "/"
}

variable "health_check_matcher" {
  type    = string
  default = "200"
}

variable "instance_ids" {
  type = map(string)
}

variable "ec2_sg_id" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "rule_map" {
  type = map(object({
    type                     = string
    from_port                = string
    to_port                  = string
    protocol                 = string
    cidr_blocks              = optional(list(string))
    source_security_group_id = optional(string)
  }))
}

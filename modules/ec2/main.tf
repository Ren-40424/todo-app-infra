resource "aws_instance" "backend" {
  for_each = toset(var.subnet_ids)

  subnet_id              = each.value
  instance_type          = var.instance_type
  ami                    = var.ami_id
  vpc_security_group_ids = [module.sg.id]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

module "sg" {
  source       = "../security_group"
  project_name = var.project_name
  vpc_id       = var.vpc_id

  rule_map = {
    allow_tcp_from_alb = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      cidr_blocks              = null
      source_security_group_id = var.alb_sg_id
    }

    allow_all_to_all = {
      type                     = "egress"
      from_port                = 0
      to_port                  = 0
      protocol                 = -1
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
  }
}

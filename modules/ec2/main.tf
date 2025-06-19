data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh.tpl")

  vars = {
    db_host      = var.db_address
    db_name      = var.db_name
    db_username  = var.db_username
    region       = var.aws_region
    project_name = var.project_name
    environment  = var.environment
    project_path = var.api_project_path
    user_pool_id = var.user_pool_id
    allowed_host = var.api_allowed_host
  }
}

resource "aws_instance" "this" {
  for_each = var.subnet_ids

  subnet_id              = each.value
  instance_type          = var.instance_type
  ami                    = var.ami_id
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = [module.sg.id]
  user_data              = data.template_file.user_data.rendered

  user_data_replace_on_change = true

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
      from_port                = 3000
      to_port                  = 3000
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

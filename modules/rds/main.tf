locals {
  db_secrets_version = 1
}

ephemeral "random_password" "db_password" {
  length           = 16
  override_special = "!#$%*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "db_password" {
  name             = "/${var.project_name}/${var.environment}/app/MYSQL_PASSWORD"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.db_password.result # 生成したランダムパスワードを呼び出す
  value_wo_version = local.db_secrets_version
}

ephemeral "aws_ssm_parameter" "db_password" {
  arn = aws_ssm_parameter.db_password.arn
}

resource "aws_db_subnet_group" "this" {
  subnet_ids = toset(values(var.subnet_ids))
}

resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-rds"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  username               = var.db_username
  password_wo            = ephemeral.aws_ssm_parameter.db_password.value
  password_wo_version    = local.db_secrets_version
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [module.sg.id]
  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot

  tags = {
    Name = "${var.project_name}-rds"
  }
}

module "sg" {
  source       = "../security_group"
  project_name = var.project_name
  vpc_id       = var.vpc_id

  rule_map = {
    allow_mysql_from_ec2 = {
      type                     = "ingress"
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      cidr_blocks              = null
      source_security_group_id = var.ec2_sg_id
    }
  }
}

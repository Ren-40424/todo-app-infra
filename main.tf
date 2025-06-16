module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
}

module "subnet" {
  source       = "./modules/subnet"
  aws_region   = var.aws_region
  project_name = var.project_name
  vpc_id       = module.vpc.id
  subnets      = var.subnets
  igw_id       = module.vpc.igw_id
}

module "ec2" {
  source        = "./modules/ec2"
  project_name  = var.project_name
  subnet_ids    = module.subnet.ids_by_usage["ec2"]
  instance_type = var.instance_type
  ami_id        = var.ami_id
  vpc_id        = module.vpc.id
  alb_sg_id     = "dummy"
}

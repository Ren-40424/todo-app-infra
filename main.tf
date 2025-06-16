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

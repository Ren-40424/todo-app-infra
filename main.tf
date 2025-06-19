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

module "iam_instance_profile" {
  source       = "./modules/iam_instance_profile"
  project_name = var.project_name
}

module "ec2" {
  source               = "./modules/ec2"
  project_name         = var.project_name
  subnet_ids           = module.subnet.ids_by_usage["ec2"]
  instance_type        = var.instance_type
  ami_id               = var.ami_id
  vpc_id               = module.vpc.id
  alb_sg_id            = module.alb.sg_id
  iam_instance_profile = module.iam_instance_profile.name
  db_name              = var.db_name
  db_username          = var.db_username
  db_address           = module.rds.address
  aws_region           = var.aws_region
  environment          = var.environment
  api_project_path     = var.api_project_path
  user_pool_id         = var.user_pool_id
  api_allowed_host     = var.api_allowed_host
}

module "alb" {
  source               = "./modules/alb"
  project_name         = var.project_name
  vpc_id               = module.vpc.id
  subnet_ids           = module.subnet.ids_by_usage["alb"]
  certificate_arn      = module.acm.alb_cert_arn
  health_check_path    = var.alb_health_check_path
  health_check_matcher = var.alb_health_check_matcher
  instance_ids         = module.ec2.instance_ids
  route53_zone_id      = var.route53_zone_id
  domain_name          = var.domain_name
  ec2_sg_id            = module.ec2.sg_id
}

module "rds" {
  source         = "./modules/rds"
  project_name   = var.project_name
  environment    = var.environment
  subnet_ids     = module.subnet.ids_by_usage["rds"]
  instance_class = var.db_instance_class
  db_username    = var.db_username
  db_name        = var.db_name
  vpc_id         = module.vpc.id
  ec2_sg_id      = module.ec2.sg_id
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.app_bucket_name
}

module "cloudfront" {
  source                         = "./modules/cloudfront"
  project_name                   = var.project_name
  domain_name                    = var.domain_name
  app_default_root_object        = var.app_default_root_object
  s3_bucket_regional_domain_name = module.s3.app_bucket_regional_domain_name
  route53_zone_id                = var.route53_zone_id
  cf_cert_arn                    = module.acm.cf_cert_arn
}

module "acm" {
  source          = "./modules/acm"
  project_name    = var.project_name
  environment     = var.environment
  owner           = var.owner
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
}

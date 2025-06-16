terraform {
  required_providers {
    aws = {
      version = ">=5.94.0"
    }
  }

  backend "s3" {
    bucket  = var.backend_bucket_name
    region  = var.aws_region
    key     = "env/${var.environment}/terraform.tfstate"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
      Managed_by  = "terraform"
    }
  }
}
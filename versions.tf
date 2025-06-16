terraform {
  required_providers {
    aws = {
      version = ">=5.94.0"
    }
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
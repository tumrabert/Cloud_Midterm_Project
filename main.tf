terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}
provider "aws" {
    region = var.region
  
}

module "S3" {
    source = "./modules/S3"
    bucket_name=var.bucket_name
}
module "VPC" {
  source = "./modules/VPC"

  availability_zone = var.availability_zone
  ami               = var.ami
  instance_type     = var.instance_type

  database_name = var.database_name
  database_user = var.database_user
  database_pass = var.database_pass

  admin_user = var.admin_user
  admin_pass = var.admin_pass

  iam_s3_access_key = module.S3.iam_s3_access_key
  iam_s3_secret_key = module.S3.iam_s3_secret_key
  bucket_name       = var.bucket_name
  bucket_region     = var.region

  
}


output "web_server_public_ip" {
  value = module.VPC.web_server_public_ip
}


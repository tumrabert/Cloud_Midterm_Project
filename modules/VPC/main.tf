resource "aws_vpc" "VPC" {
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id
}

module "NAT" {
    source = "./NAT"

    vpc_id = aws_vpc.VPC.id
    cidr_block = var.nat_cidr_block
    availability_zone = var.availability_zone
    igw_id = aws_internet_gateway.igw.id
  
}

module "internal_public2" {
    source = "./subnets/internal_public2"
    vpc_id=aws_vpc.VPC.id
    cidr_block=var.internal_cidr_block
    availability_zone = var.availability_zone
}

module "db_private1" {
    source = "./subnets/db_private1"

    vpc_id = aws_vpc.VPC.id
    cidr_block = var.db_cidr_block
    availability_zone = var.availability_zone
    ngw_id = module.NAT.ngw_id
    internal_eni_id = module.internal_public2.internal_db_eni_id
    inbound_db_access_cidr_block = var.internal_cidr_block
    ami = var.ami
    instance_type = var.instance_type

    database_name = var.database_name
    database_user = var.database_user
    database_pass = var.database_pass
}

module "web_public1" {
    source = "./subnets/web_public1"

    depends_on = [ aws_internet_gateway.igw,module.db_private1 ]

    vpc_id = aws_vpc.VPC.id
    cidr_block = var.web_cidr_block
    availability_zone = var.availability_zone
    igw_id = aws_internet_gateway.igw.id
    internal_eni_id = module.internal_public2.internal_web_eni_id
    ami = var.ami
    instance_type = var.instance_type

    database_name = var.database_name
    database_user = var.database_user
    database_pass = var.database_pass
    database_host = module.internal_public2.internal_db_private_ip

    admin_user = var.admin_user
    admin_pass = var.admin_pass

    iam_s3_access_key = var.iam_s3_access_key
    iam_s3_secret_key = var.iam_s3_secret_key
    bucket_name       = var.bucket_name
    bucket_region     = var.bucket_region
}

output "web_server_public_ip" {
  value = module.web_public1.web_server_public_ip
}
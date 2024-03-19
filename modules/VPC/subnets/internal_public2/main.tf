resource "aws_subnet" "internal_public1" {
    vpc_id  =var.vpc_id
    cidr_block = var.cidr_block
    availability_zone = var.availability_zone
  
}

resource "aws_network_interface" "internal_web" {
    subnet_id = aws_subnet.internal_public1.id
  
}

resource "aws_network_interface" "internal_db" {
  subnet_id = aws_subnet.internal_public1.id
}

output "internal_web_eni_id" {
  value = aws_network_interface.internal_web.id
}

output "internal_db_eni_id" {
  value = aws_network_interface.internal_db.id
}

output "internal_db_private_ip" {
  value = aws_network_interface.internal_db.private_ip
}
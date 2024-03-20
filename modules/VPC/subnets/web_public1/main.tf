resource "aws_subnet" "web_public1" {
  vpc_id = var.vpc_id
  cidr_block = var.cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "subnet_web_public1"
  }
}

resource "aws_route_table" "web_rtb" {

vpc_id=var.vpc_id

route{
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
}

tags = {
    Name = "web_server_rtb"
  }
}

resource "aws_route_table_association" "web_rtb" {
  subnet_id = aws_subnet.web_public1.id
  route_table_id = aws_route_table.web_rtb.id
  
}

resource "aws_security_group" "sg_web" {
  name="sg_web"
  description = "Security group for the web server"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow inbound traffic on port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_network_interface" "web_public1" {
  subnet_id       = aws_subnet.web_public1.id
  security_groups = [aws_security_group.sg_web.id]

  tags = {
    Name = "eni-web-public"
  }
}

resource "aws_eip" "web_eip" {
  vpc=true
  network_interface = aws_network_interface.web_public1.id

}

resource "aws_instance" "web_server" {

    depends_on = [ aws_eip.web_eip ]

    ami = var.ami
    instance_type = var.instance_type
    availability_zone = var.availability_zone

    network_interface {
      network_interface_id = aws_network_interface.web_public1.id
      device_index = 0
    }

    network_interface {
      network_interface_id = var.internal_eni_id
      device_index = 1
    }

      user_data = templatefile("init-wordpress.tftpl", {
    web_public_ip     = aws_eip.web_eip.public_ip
    database_name     = var.database_name
    database_user     = var.database_user
    database_pass     = var.database_pass
    database_host     = var.database_host
    admin_user        = var.admin_user
    admin_pass        = var.admin_pass
    iam_s3_access_key = var.iam_s3_access_key
    iam_s3_secret_key = var.iam_s3_secret_key
    bucket_name       = var.bucket_name
    bucket_region     = var.bucket_region
  })

  tags = {
    Name = "webserver-ec2-instance" 
  }
  
}

output "web_server_public_ip" {
    value = aws_instance.web_server.public_ip
  
}
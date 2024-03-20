resource "aws_subnet" "nat_public" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone

  tags = {
    Name = "subnet-nat-webpublic1"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "webpublic1_eip-nat"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat_public.id

  tags = {
    Name = "webpublic1_ngw"
  }
}

resource "aws_route_table" "nat_rtb" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "webpublic1_rtb"
  }
}

resource "aws_route_table_association" "nat_rtb" {
  subnet_id      = aws_subnet.nat_public.id
  route_table_id = aws_route_table.nat_rtb.id
  
}

output "ngw_id" {
  value = aws_nat_gateway.ngw.id
}

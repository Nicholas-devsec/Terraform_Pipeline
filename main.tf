provider "aws" {
  region = "us-west-2"

}

resource "aws_vpc" "main_vpc" {
  cidr_block       = var.main_vpc
  instance_tenancy = "default" #shared hardware configuration

  tags = {
    name = "main"
  }

}
#tfsec:ignore:AVD-AWS-0164
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_cidr
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true #provide auto ip assosiation within subnet

  tags = {
    name = "public_subnet"
  }

}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.private_cidr
  availability_zone       = var.availability_zone2
  map_public_ip_on_launch = false

  tags = {
    name = "private_subnet"
  }

}

resource "aws_instance" "public_ec2" {
  ami           = var.ec2_ami
  instance_type = var.instance_size
  subnet_id     = aws_subnet.public_subnet.id
  depends_on = [ aws_internet_gateway.vpc_igw ]
  vpc_security_group_ids = [aws_security_group.ingress_rules.id, aws_security_group.egress_rules.id ]
  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }

  tags = {
    name = "public_instance"
  }

}

resource "aws_eip" "instance_eip" {
  instance = aws_instance.public_ec2.id
  domain   = "vpc"
}

resource "aws_instance" "private_ec2" {
  ami           = var.ec2_ami
  instance_type = var.instance_size
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.egress_rules.id]
  root_block_device {
    encrypted = true
  }

   metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }


  tags = {
    name = "private_instance"
  }

}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  #eip for the nat gateway

}


resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.nat_eip.id

  tags = {
    name = "public_nat"
  }

}

resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    name = "main"
  }

  
}

resource "aws_route_table" "vpc_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
    

  }
  tags = {
    name = "main"
  }
  
}

resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.vpc_table.id
  subnet_id = aws_subnet.public_subnet.id #routing for public subnet

    }


resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
  }

  tags = {
    name = "private_table"
  }
  
}

resource "aws_route_table_association" "private_association" {
  route_table_id = aws_route_table.private_table.id
  subnet_id = aws_subnet.private_subnet.id
  
}


resource "aws_security_group" "ingress_rules" {

  name = "ingress_rules"
  description = "rules for allowing inbound traffic"
  vpc_id = aws_vpc.main_vpc.id


  ingress { 
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["192.168.1.0/24"] #allowing ssh only from approved private subnet cidr range
  }
  #tfsec:ignore:AVD-AWS-0107
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allow public access for web server
  }
  #tfsec:ignore:AVD-AWS-0107
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #allow public access for web server
  }

 }


resource "aws_security_group" "egress_rules" {

  name = "egress_rules"
  description = "rules for what traffic is allowed outbound"
  vpc_id = aws_vpc.main_vpc.id

  #tfsec:ignore:AVD-AWS-0104
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}
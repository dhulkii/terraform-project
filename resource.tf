resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    name = "dk-vpc"
  }
}
resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    name = "dksub1"
  }
}
resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    name = "dksub2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    name = "dkigw"
  }
}
resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "myrtasso1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.myRT.id
}
resource "aws_route_table_association" "myrtasso2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.myRT.id
}

resource "aws_security_group" "web-Sg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    description = "allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      description = "allow HTTPS"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
    ingress {
      description = "allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

resource "aws_security_group" "alb-sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "allow outbound all traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


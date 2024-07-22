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
resource "aws_instance" "ec2-1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web-Sg.id]
  subnet_id              = aws_subnet.public-1.id
  key_name               = var.key_name
  tags = {
    Name = "we-app-guarder"
  }
}
resource "aws_instance" "ec2-2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web-Sg.id]
  subnet_id              = aws_subnet.public-2.id
  key_name               = var.key_name
  tags = {
    Name = "web-app-kider"
  }
}
resource "aws_lb_target_group" "TG1" {
  target_type = "instance"
  name     = "TG-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}
resource "aws_lb_target_group" "TG2" {
  name     = "TG-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id
}


resource "aws_lb_target_group_attachment" "TG-1-attach" {
  target_group_arn = aws_lb_target_group.TG1.arn
  target_id        = aws_instance.ec2-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "TG-2-attach" {
  target_group_arn = aws_lb_target_group.TG2.arn
  target_id        = aws_instance.ec2-2.id
  port             = 80
}
resource "aws_lb" "LB" {
  name               = "dk-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public-1.id, aws_subnet.public-2.id]
}
resource "aws_lb_listener" "listener-default" {
  load_balancer_arn = aws_lb.LB.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG1.arn
    }
}
resource "aws_lb_listener_rule" "rule-1" {
  listener_arn = aws_lb_listener.listener-default.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG1.arn
  }
  condition {
    path_pattern {
      values = ["/guarder/*"]
    }
  }
}
resource "aws_lb_listener_rule" "rule-2" {
  listener_arn = aws_lb_listener.listener-default.arn
  priority     = 2
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG2.arn
  }
  condition {
    path_pattern {
      values = ["/kider/*"]
    }
  }
}

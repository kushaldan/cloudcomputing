provider "aws" {
  region = "us-east-1" # Change this to your desired region
}

data "aws_availability_zones" "available" {}

resource "aws_default_vpc" "default" {
  
  tags = {
    Name = "default1"
  }
}
  
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Security group for Nginx instances"
  vpc_id = aws_default_vpc.default.id

  # Define your security group rules here
  # Example: allow ingress traffic on port 80 for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress{
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Add more rules as needed
}  

resource "aws_default_subnet" "subnet1" {
  
  availability_zone       = "us-east-1a"  # Replace with your desired AZ
  tags = {
    Name= "subnet1"
  }
}

resource "aws_default_subnet" "subnet2" {
  
  availability_zone       = "us-east-1b"  # Replace with a different AZ
  tags = {
    Name= "subnet2"
  }
}



resource "aws_launch_configuration" "nginx_lc" {
  name_prefix   = "nginx-lc-"
  image_id      = "ami-03a6eaae9938c858c" # Your desired AMI ID
  instance_type = "t2.micro" # Change to your desired instance type

  key_name = var.key_name 
  security_groups = [aws_security_group.nginx_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install nginx -y
  sudo systemctl start nginx
  sudo systemctl enable nginx
  EOF
  

  
}

resource "aws_autoscaling_group" "nginx_asg" {
  name_prefix          = "nginx-asg-"
  launch_configuration = aws_launch_configuration.nginx_lc.name
  min_size             = 2 # Minimum instances
  max_size             = 5 # Maximum instances
  desired_capacity     = 2 # Initial instances

  vpc_zone_identifier = [
    aws_default_subnet.subnet1.id, # Replace with your subnet IDs
    aws_default_subnet.subnet2.id  # Replace with your subnet IDs
  ]
}
resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"

  enable_deletion_protection = false

  # Specify the subnets in two different Availability Zones
  subnets = [
    aws_default_subnet.subnet1.id, # Replace with the ID of your subnet in AZ 1
    aws_default_subnet.subnet2.id  # Replace with the ID of your subnet in AZ 2
  ]

  enable_http2 = true

  # ... other ALB settings
}


resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
          }
  }
}

output "load_balancer_dns" {
  value = aws_lb.nginx_lb.dns_name
}

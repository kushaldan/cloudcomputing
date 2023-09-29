variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1" # Change this to your desired region
}

# Define other variables as needed
# Define the variables for the script


variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  
  default     = "10.0.1.0/24"
}

variable "ami_id" {
  description = "The AMI ID to use for the instances"
  default     = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2 AMI
}

variable "instance_type" {
  description = "The instance type to use for the instances"
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name to use for the instances"
  default     = "demo"
}

variable "min_size" {
  description = "The minimum size of the Autoscaling group"
  default     = 2
}

variable "max_size" {
  description = "The maximum size of the Autoscaling group"
  default     = 4
}

variable "desired_capacity" {
  description = "The desired capacity of the Autoscaling group"
  default     = 3
}
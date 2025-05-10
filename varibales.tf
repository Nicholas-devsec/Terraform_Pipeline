variable "main_vpc" {
  description = "vpc cidir"
  type        = string
  default     = "10.0.0.0/16"

}

variable "public_cidr" {
  description = "public subent cidr"
  type        = string
  default     = "10.0.0.1/24"

}

variable "availability_zone1" {
  description = "for public subnets"
  type        = string

}

variable "private_cidr" {
  description = "private subnet cidr"
  type        = string
  default     = "10.0.1.0/24"

}

variable "availability_zone2" {
  description = "for private subnets"
  type        = string

}

variable "ec2_ami" {
  description = "image for our instances"
  type        = string
  default     = "ami-004e1dc83789471c1"


}

variable "instance_size" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"

}
variable "env" {
    description = "this is the enviroment for my ec2"
    type = string
  
}
variable "vpc_id" {
    description = "this is the vpc_id for my ec2"
    type = string
  
}

variable "subnet_id" {
    description = "subnet for my app"
  
}
variable "public_subnet_id" {
    description = "subnet for my app"
  
}
variable "ami" {
    description = "ami id for my ec2 seever "
  
}
variable "instance_type" {
    description = "ami id for my ec2 seever "
  
}


variable "app_subnet_id" {
  description = "subnet for application subnets"
  type        = list(string)
}




variable "my_ip" {
    description = "this is the vpc_id for my ec2"
    type = string
  
}

variable "external_alb_sg_id" {
    type = string
  
}

variable "internal_alb_sg_id" {
    type = string
  
}
variable "env" {
    description = "this is the enviroment for my cutsom vpc"
    type = string
    default = "dev"
  
}
variable "vpc_id" {
    description = "this is the vpc_id for my ec2"
    type = string
  
}

variable "my_ip" {
    description = "this is the vpc_id for my ec2"
    type = string
  
}

variable "backend_ec2_sg_id" {
    type = string
  
}

variable "db_username" {
    type = string
  
}

variable "db_password" {
    type = string
    sensitive = true
  
}
variable "db_subnet_id" {
  description = "subnet for application subnets"
  type        = list(string)
}
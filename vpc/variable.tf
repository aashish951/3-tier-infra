variable "vpc_cidr_block" {
    description = "this the cidr block range for my customvpc"
    type = string
    default = "10.0.0.0/16"
  
}

variable "cidr_block" {
    description = "this the cidr block range for my customvpc"
    type = string
    default = "0.0.0.0/0"
  
}

variable "env" {
    description = "this is the enviroment for my cutsom vpc"
    type = string
    default = "dev"
  
}

variable "az" {
    description = "this is the availiblity zone for my cutsom vpc"
    type = list(string)
    default = ["us-east-1a","us-east-1b"]
  
}

variable "public_subnet_cidrs" {
    description = "this is the public cidr for my cutsom vpc"
    type = list(string)
    default = ["10.0.1.0/24","10.0.2.0/24"]
  
}

variable "app_subnet_cidrs" {
    description = "this is the app cidr for my cutsom vpc"
    type = list(string)
    default = ["10.0.3.0/24","10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]

  
}

variable "db_subnet_cidrs" {
    description = "this is the app cidr for my cutsom vpc"
    type = list(string)
    default = ["10.0.16.0/24","10.0.32.0/24"]
    
  
}






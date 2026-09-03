variable "env" {
    description = "this is the enviroment for my cutsom vpc"
    type = string
    default = "dev"
  
}
variable "vpc_id" {
    description = "this is the vpc_id for my ec2"
    type = string
  
}
variable "public_subnet_id" {
    type = list(string)
  
}

variable "app_subnet_id" {
    type = list(string)
  
}



 variable "frontend_instance_ids" {
    type = list(string)
 }

  variable "backend_instance_ids" {
    type = list(string)
 }



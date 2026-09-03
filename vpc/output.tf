output "vpc_id" {
    value = aws_vpc.my_vpc.id
   
    description = "vpc id formy architecture "  
}

output "public_subnet_id" {
    value = aws_subnet.public_subnet[*].id
   
    description = "public subnet id formy architecture "  
}
output "app_subnet_id" {
    value = aws_subnet.app_subnet[*].id
    
    description = "app subnet id formy architecture "  
}

output "db_subnet_id" {
    value = aws_subnet.db_subnet[*].id
    
    description = "public subnet id formy architecture "  
}
output "app_subnet_cidrs" {
    value = var.app_subnet_cidrs
  
}
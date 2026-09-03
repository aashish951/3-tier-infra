output "backend_ec2_sg_id" {
    value = aws_security_group.backend_ec2_sg.id

  
}
output "frontend_instance_ids" {
    value = aws_instance.frontend_app[*].id
  
}

output "backend_instance_ids" {
    value = aws_instance.backend_app[*].id
  
}
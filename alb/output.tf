output "external_alb_sg_id" {
    value = aws_security_group.external_alb_sg.id
  
}

output "internal_alb_sg_id" {
    value = aws_security_group.internal_alb_sg.id
  
}
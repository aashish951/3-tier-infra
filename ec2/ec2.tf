resource "aws_key_pair" "my_key" {
    key_name = "${var.env}-3-tier-ec2"
    public_key = file("terra-key-ec2.pub")
    
    
    tags = {
      Name = "${var.env}-3-tier-key-pair"
      environment =  var.env
    }
  
}


resource "aws_security_group" "bostion_host" {
   vpc_id = var.vpc_id
   
    tags = {
      Name = "${var.env}-bostion_host"
      environment =  var.env
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
        description = "ssh through my ip "
    }

    egress  {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "open for all"

    }
  
}

resource "aws_instance" "bostion_ec2" {
    count = 1
    subnet_id = var.public_subnet_id[count.index]
    vpc_security_group_ids = [aws_security_group.bostion_host.id]
    ami = var.ami
    key_name = aws_key_pair.my_key.key_name
    instance_type = var.instance_type
    monitoring = true
    tags = {
      Name = "${var.env}-bostion_host"
      environment =  var.env
    }
}

resource "aws_eip" "bostion_eip" {
    domain = "vpc"
    instance = aws_instance.bostion_ec2[0].id
    tags = {
      Name = "${var.env}-bostion_eip"
      environment =  var.env
    }

  
}
resource "aws_security_group" "frontend_ec2_sg" {
   vpc_id = var.vpc_id
   
    tags = {
      Name = "${var.env}-frontend_ec2_sg"
      environment =  var.env
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ var.external_alb_sg_id ]
        description = "http"
    }
    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bostion_host.id]
    description     = "SSH only via bostion"
  }

    egress  {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "open for all"

    }
  
}

resource "aws_instance" "frontend_app" {
    count = 2
    subnet_id = var.app_subnet_id[count.index]
    vpc_security_group_ids = [aws_security_group.frontend_ec2_sg.id]
    ami = var.ami
    key_name = aws_key_pair.my_key.key_name
    instance_type = var.instance_type
    user_data = file("${path.module}/install_nginx.sh")
    tags = {
      Name = "${var.env}-frontend{count.index +1}"
      environment =  var.env
    }
    
  
}
resource "aws_security_group" "backend_ec2_sg" {
   vpc_id = var.vpc_id
   
    tags = {
      Name = "${var.env}-backend_ec2_sg"
      environment =  var.env
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ var.internal_alb_sg_id ]
        description = "http"
    }
    ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bostion_host.id]
    description     = "SSH only via bostion"
  }

    egress  {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "open for all"

    }
  
}

resource "aws_instance" "backend_app" {
    count = 2
    subnet_id = var.app_subnet_id[count.index ]
    vpc_security_group_ids = [aws_security_group.backend_ec2_sg.id]
    ami = var.ami
    key_name = aws_key_pair.my_key.key_name
    instance_type = var.instance_type
    user_data = file("${path.module}/install_nginx.sh")
    tags = {
      Name = "${var.env}-backend-${count.index+1}"
      environment =  var.env
    }
    
  
}

resource "aws_security_group" "external_alb_sg" {
     vpc_id = var.vpc_id
   
    tags = {
      Name = "${var.env}-external_alb_sg"
      environment =  var.env
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "rds"
    }
    egress  {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_security_group" "internal_alb_sg" {
     vpc_id = var.vpc_id
   
    tags = {
      Name = "${var.env}-internal_alb_sg"
      environment =  var.env
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [ aws_security_group.external_alb_sg.id ]
        description = "rds"
    }
    egress  {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_lb" "external_alb" {
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.external_alb_sg.id]
  subnets =  var.public_subnet_id 

  tags = {
      Name = "${var.env}-frontend_alb"
      environment =  var.env
    }
}


resource "aws_lb_target_group" "frontend_tg" {
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id

  health_check {
    path = "/"
    port = "traffic-port"
     protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200,404" 
  }

  tags = {
      Name = "${var.env}-frontend_tg"
      environment =  var.env
    }

  
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  tags = {
      Name = "${var.env}-frontend_listner"
      environment =  var.env
    }
  
}
resource "aws_lb_target_group_attachment" "frontend_attachment" {
  count = length(var.frontend_instance_ids)
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id = var.frontend_instance_ids[count.index]
  port = 80
  
}



resource "aws_lb" "internal_alb" {
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.internal_alb_sg.id  ]
  subnets = var.app_subnet_id 
  tags = {
      Name = "${var.env}-backend_alb"
      environment =  var.env
    }
  
}

resource "aws_lb_target_group" "backend_tg" {
 port = 80
 protocol = "HTTP"
 vpc_id = var.vpc_id
 
 health_check {
   path = "/"
   port = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200,404" 
 }
  tags = {
      Name = "${var.env}-backend_tg"
      environment =  var.env
    }
  
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  tags = {
      Name = "${var.env}-backend_listner"
      environment =  var.env
    }
  
}

resource "aws_lb_target_group_attachment" "backend_attachment" {
  count = length(var.backend_instance_ids)
  target_group_arn = aws_lb_target_group.backend_tg.arn
  target_id = var.backend_instance_ids[count.index]
  port = 80

 
  
}





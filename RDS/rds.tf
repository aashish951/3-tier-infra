resource "aws_security_group" "rds_sg" {
   vpc_id = var.vpc_id
   
    tags = {
      Name = "${var.env}-rds_sg"
      environment =  var.env
    }
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [var.backend_ec2_sg_id ]
        description = "rds"
    }
     egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks =  ["0.0.0.0/0"]
        description = "from all ports "

    }

    
}
resource "aws_db_subnet_group" "subnet_group" {
    subnet_ids = var.db_subnet_id
    name = "${var.env}-db_subnet_group"
  
}

resource "aws_db_instance" "db" {
    instance_class = "db.t3.micro"
    allocated_storage = 20
    engine = "mysql"
    db_name = "mydb"
    username = var.db_username
    password = var.db_password
    skip_final_snapshot = true
    vpc_security_group_ids = [ aws_security_group.rds_sg.id ]
    db_subnet_group_name =   aws_db_subnet_group.subnet_group.name
  
}
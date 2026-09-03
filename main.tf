module "vpc" {
    source = "./vpc"
   vpc_cidr_block = "10.0.0.0/16"
  cidr_block = "0.0.0.0/0"
  env = "dev"
  az = ["us-east-1a","us-east-1b"]
  public_subnet_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
  app_subnet_cidrs = ["10.0.3.0/24","10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]
  db_subnet_cidrs = ["10.0.16.0/24","10.0.32.0/24"]
}

module "ec2" {
    source = "./ec2"
    env = "dev"
    vpc_id = module.vpc.vpc_id
    subnet_id = module.vpc.app_subnet_id
    public_subnet_id = module.vpc.public_subnet_id
    ami = "ami-0b6d9d3d33ba97d99"
    instance_type = "t3.micro"
    app_subnet_id = module.vpc.app_subnet_id
    my_ip = "0.0.0.0/0"
    external_alb_sg_id = module.alb.external_alb_sg_id
    internal_alb_sg_id = module.alb.internal_alb_sg_id


   
    
    
    
  
}
module "rds" {
    source = "./RDS"
    env = "dev"
    vpc_id = module.vpc.vpc_id
    my_ip = "0.0.0.0/0"
    backend_ec2_sg_id = module.ec2.backend_ec2_sg_id
    db_subnet_id = module.vpc.db_subnet_id
    db_username   = var.db_username    
  db_password   = var.db_password

  
}
module "alb" {
    source = "./alb"
    env = "dev"
    vpc_id = module.vpc.vpc_id
    app_subnet_id =[ module.vpc.app_subnet_id[0],
                      module.vpc.app_subnet_id[1]]
    public_subnet_id = module.vpc.public_subnet_id
    frontend_instance_ids = module.ec2.frontend_instance_ids
    backend_instance_ids = module.ec2.backend_instance_ids

  
}




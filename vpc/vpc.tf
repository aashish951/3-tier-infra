resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "${var.env}-custom vpc"
      environment =  var.env
    }

  
}

resource "aws_subnet" "public_subnet" {
    count = length(var.public_subnet_cidrs)
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = var.az[count.index]

    tags = {
      Name ="${var.env}-public-${count.index+1}"
      environment = var.env
    }
  
}
resource "aws_subnet" "app_subnet" {
    count = length(var.app_subnet_cidrs)
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.app_subnet_cidrs[count.index]
    availability_zone = var.az[count.index % length(var.az)]

    tags = {
      Name ="${var.env}-app-${count.index+1}"
      environment = var.env
    }
  
}

resource "aws_subnet" "db_subnet" {
    count = length(var.db_subnet_cidrs)
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.db_subnet_cidrs[count.index]
    availability_zone = var.az[count.index]

    tags = {
      Name ="${var.env}-db-${count.index+1}"
      environment = var.env
    }
  
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
    
  tags = {
    Name = "${var.env}-public-igw"
    environment = var.env
  }
}
resource "aws_eip" "elastic_ip" {
  domain = "vpc"
  tags = {
    Name = "${var.env}-elastic"
    environment = var.env
  }

  
}
resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.elastic_ip.id
    subnet_id = aws_subnet.public_subnet[0].id
    depends_on = [ aws_internet_gateway.igw ]
    
  tags = {
    Name = "${var.env}-nat"
    environment = var.env
  }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.my_vpc.id
    
    route  {
      gateway_id = aws_internet_gateway.igw.id
      cidr_block = "0.0.0.0/0"
    }

    tags = {
    Name = "${var.env}-public-rt"
    environment = var.env
  }
  
}


resource "aws_route_table_association" "public_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id

  
}
resource "aws_route_table" "app_rt" {
    vpc_id = aws_vpc.my_vpc.id
    
    route  {
      nat_gateway_id = aws_nat_gateway.nat.id
      cidr_block = "0.0.0.0/0"
    }

    tags = {
    Name = "${var.env}-app-rt"
    environment = var.env
  }
  
}
resource "aws_route_table_association" "app_association" {
  count = length(var.app_subnet_cidrs)
  subnet_id = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_rt.id

  
}
resource "aws_route_table" "db_rt" {
    vpc_id = aws_vpc.my_vpc.id
    
    

    tags = {
    Name = "${var.env}-db-rt"
    environment = var.env
  }
  
}
resource "aws_route_table_association" "db_association" {
  count = length(var.db_subnet_cidrs)
  subnet_id = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db_rt.id

  
}

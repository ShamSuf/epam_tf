#########
## VPC ##
#########
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "epam" 
  }
}

resource "aws_subnet" "subnet_private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "subnet_public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

#########
## IGW ##
##########
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

#################
## NAT Gateway ##
#################
# resource "aws_eip" "nat_eip" {
#   domain = vpc
# }

resource "aws_nat_gateway" "nat" {
  allocation_id = "eipalloc-053a0763862fbbbe5"
  subnet_id     = aws_subnet.subnet_public.id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

   tags = {
    Name = "epam-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "epam-private-rt"
  }
}
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.subnet_public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.private.id
}

#####################
## Security Groups ##
#####################

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Allow HTTP and HTTPS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
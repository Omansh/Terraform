provider "aws" {
  region = "ap-south-1"
}

#Creating a VPC with the tag TerraformVPC and the CIDR block "192.168.0.0/16"
resource "aws_vpc" "testvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"


  tags = {
    Name = "TerraformVPC"
  }
}

#Creating and interent gateway with the tag InternetGateway and attaching it to the TerraformVPC
resource "aws_internet_gateway" "igateway" {
  vpc_id = aws_vpc.testvpc.id

  tags = {
    Name = "InternetGateway"
  }
}

#Creating the route table
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.testvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igateway.id
  }

  tags = {
    Name = "Route-Table1"
  }
}

#Creating the subnet under the TerraformVPC with the CIDR block "192.168.0.0/24" and with the Tag as Subnet1
resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.testvpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Subnet1"
  }
}

#Associating the subnet i.e Subnet1 with the Route-Table1
resource "aws_route_table_association" "rtst_association" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.route-table.id
}


#Creating a Security Group and allowing HTTP & SSH
resource "aws_security_group" "allow_web" {
  name        = "Allow HTTP"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.testvpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #-1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

#Creating a network interface with an ip in the subnet that we have created above
resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.0.20"]
  security_groups = [aws_security_group.allow_web.id]
}

#Assigning an elastic ip to network interface created above
resource "aws_eip" "elasticeip" {
  vpc                       = true
  network_interface         = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.0.20"
  depends_on                = [aws_internet_gateway.igateway]

}

#Creating a web server, install and enable apache on it
resource "aws_instance" "web-server-instance" {
  ami               = "ami-0e306788ff2473ccb"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "tgr-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web_server_nic.id
  }

  user_data = file("server-script.sh")

  tags = {
    Name = "Web-Server"
  }
}


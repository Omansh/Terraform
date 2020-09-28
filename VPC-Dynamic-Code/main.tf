provider "aws" {
    region = "ap-south-1"
}

#Creating a VPC with the values enterred by the user

#Variable to set the VPC name
variable "setvpc_name" {
    type = string
    description = "Set the name of your VPC"
}
#Variable to set the CIDR Block for the VPC
variable "setvpc_cidrblock" {
    type = string
    description = "Give CIDR Block for the VPC"
}
#VPC Creation
resource "aws_vpc" "testvpc" {
  cidr_block       = var.setvpc_cidrblock
  instance_tenancy = "default"
  tags = {
    Name = var.setvpc_name
  }
}

#Creating an interent gateway with the tag InternetGateway and attaching it to the VPC that will get created
resource "aws_internet_gateway" "igateway" {
  vpc_id = aws_vpc.testvpc.id

  tags = {
    Name = "Terraform InternetGateway"
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



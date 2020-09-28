provider "aws" {
  region = "ap-south-1"
}


variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22] #Define ports that you would like to open for inbound rules.
}

variable "egressrules" {
  type    = list(number)
  default = [80, 443, 25, 3306, 53, 8080] #Define ports that you would like to open for outbound rules.
}

#Creating an EC2
resource "aws_instance" "ec2" {
  ami             = "ami-0e306788ff2473ccb"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.webtraffic.name]
  key_name        = "tgr-key"
  tags = {
    Name = "Demo EC2"
  }
}

#Creating a Security Group and opening the ports using Dynamic block
resource "aws_security_group" "webtraffic" {
  name = "Allow Web Traffic"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    iterator = port
    for_each = var.egressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}

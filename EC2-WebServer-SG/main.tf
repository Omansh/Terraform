provider "aws" {
  region = "ap-south-1"
}

#Setting up an EC2 in the ap-south-1a availabilty zone with the instance type t2.micro.
resource "aws_instance" "ec2" {
  ami               = "ami-0e306788ff2473ccb"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "tgr-key"
  security_groups   = [aws_security_group.webtraffic.name]
  user_data         = file("server-script.sh")
  tags = {
    Name = "Web-Server"
  }

}

#Creating a Security Group for the Web server and opening HTTP(80) & HTTPS(443) on it.
resource "aws_security_group" "webtraffic" {
  name = "Allow Web Traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #-1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "WebServerPublicIP" {
  value = aws_instance.ec2.public_ip
}


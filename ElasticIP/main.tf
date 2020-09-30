provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "ec2" {
  ami               = "ami-0e306788ff2473ccb"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "tgr-key"
  tags = {
      Name = "Web-Server"
  }
}

#Attaching Elastic IP to the instance creted above
resource "aws_eip" "elasticeip" {
  instance = aws_instance.ec2.id
}

#Outputs the public IP
output "EIP" {
  value = aws_eip.elasticeip.public_ip
}


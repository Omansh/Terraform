provider "aws" {
  region = "ap-south-1"
}

#Setting up an EC2 in the ap-south-1a availabilty zone with the instance type t2.micro
resource "aws_instance" "ec2" {
  ami               = "ami-0e306788ff2473ccb"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name          = "tgr-key"

}

#Outputs the private ip of the EC2 created above
output "EC2PrivateIP" {
  value = aws_instance.ec2.private_ip
}

#Outputs the public ip of the EC2 created above
output "EC2PublicIP" {
  value = aws_instance.ec2.public_ip
}
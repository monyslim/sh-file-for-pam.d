terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws", 
        version = "~> 5.0"   
    }  
  }
}

provider "aws" {
    region = "us-east-1"
}
//Create keypair for my instance
resource "tls_private_key" "usr_mgt"{
    algorithm = "RSA"
    rsa_bits = "4096"
}
resource "aws_key_pair" "usr_mgt"{
    key_name = "usr_mgt"
    public_key = tls_private_key.usr_mgt.public_key_openssh
}
//save the private key
resource "local_file" "usr_mgt"{
    content = tls_private_key.usr_mgt.private_key_pem
    filename = "usr_mgt.pem"
}
//Create an instance
resource "aws_instance" "usr_mgt"{
    ami = "ami-080e1f13689e07408"
    instance_type = "t2.micro"
    count = 1
    key_name = aws_key_pair.usr_mgt.key_name
    associate_public_ip_address = true
    # user_data = file("")
    tags = {
        Name = "usr_mgt"
    }
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file(local_file.usr_mgt.filename)
        host = self.public_ip
    }
    provisioner "remote-exec" {
        script = "file.sh"
        when = create
    }

}
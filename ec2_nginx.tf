data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.security-group.id]
  subnet_id                   = aws_subnet.private-subnet-a.id
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/sh
sudo amazon-linux-extras enable epel
sudo yum install -y epel-release -y
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

EOF
  
  tags = {
    Name = "nginx-default"
  }

}

resource "aws_security_group" "security-group" {
  name = "siemens-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
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

output "nginx_domain" {
  value = aws_instance.instance.public_dns
}

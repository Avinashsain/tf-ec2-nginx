# -------------------------------------------------------
# main.tf — EC2 Nginx Deployment with Terraform
# Provisions a t2.micro Ubuntu instance running Nginx
# in the default VPC with HTTP + SSH access.
# -------------------------------------------------------

# -------------------------------------------------------
# 1. AWS Provider & Region
# -------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# -------------------------------------------------------
# 2. Data source — look up the default VPC automatically
# -------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# -------------------------------------------------------
# 3. Data source — latest Ubuntu 20.04 LTS AMI
#    (owner: Canonical's official AWS account)
# -------------------------------------------------------
data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------------------------------------
# 4. SSH Key Pair
#    Reads your LOCAL public key (~/.ssh/id_rsa.pub) and
#    uploads it to AWS as a named key pair.
#    Generate the key first with:
#      ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
# -------------------------------------------------------
resource "aws_key_pair" "nginx_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

  tags = {
    Name      = "nginx-ssh-key"
    ManagedBy = "Terraform"
  }
}

# -------------------------------------------------------
# 5. Security Group — allow inbound HTTP (80) & SSH (22)
# -------------------------------------------------------
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Allow inbound HTTP and SSH traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nginx-security-group"
    Environment = "assignment"
    ManagedBy   = "Terraform"
  }
}

# -------------------------------------------------------
# 6. EC2 Instance — Ubuntu 20.04, t2.micro
# -------------------------------------------------------
resource "aws_instance" "nginx_server" {
  ami                         = data.aws_ami.ubuntu_20_04.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.nginx_key.key_name
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    html_content_title = var.html_title
    html_content_body  = var.html_body
  })

  tags = {
    Name        = "terraform-nginx-ubuntu"
    Environment = "assignment"
    ManagedBy   = "Terraform"
  }
}

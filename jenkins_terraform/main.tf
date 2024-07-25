resource "aws_security_group" "Jenkins_sg" {
  name        = "Jenkins_SG"
  description = "Open 22,443,80,8080,9000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080, 9000, 3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins_sg"
  }
}


resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t2.large"
  key_name               = "Jenkins_CICD"
  vpc_security_group_ids = [aws_security_group.Jenkins_sg.id]
  user_data              = templatefile("./jenkins_docker_trivy_install.sh", {})

  tags = {
    Name = "Jenkins_SQ"
  }
  root_block_device {
    volume_size = 30
  }
}
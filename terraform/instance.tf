resource "aws_security_group" "allow_all" {
  name = "allow_all"
  description = "Allow all traffic in and out"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

resource "aws_instance" "instance" {
  ami = "${var.ami}"
  associate_public_ip_address = true
  key_name = "${aws_key_pair.deploy.key_name}"
  security_groups = ["${aws_security_group.allow_all.name}"]
  instance_type = "t2.micro"
  root_block_device {
    volume_size = 150
  }
}

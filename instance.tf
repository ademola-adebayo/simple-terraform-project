resource "aws_instance" "dove_inst" {
  ami                    = lookup(var.AMIS, var.aws_REGION)
  instance_type          = "t2.micro"
  availability_zone      = var.Zone1
  key_name               = aws_key_pair.dove-key.key_name
  vpc_security_group_ids = ["sg-0780815f55104be8a"]

  tags = {
    Name    = "Dove-${var.environment}"
    Project = "Dove"
  }

  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }
  connection {
    user        = var.USERNAME
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }
}


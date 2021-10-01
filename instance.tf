resource "aws_key_pair" "dove-key" {
  key_name   = "dovekey"
  public_key = file(var.PUB_KEY_PATH)
}

resource "aws_instance" "dove_inst" {
  ami                    = var.AMIS[var.REGION]
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE1
  key_name               = aws_key_pair.dove-key.key_name
  vpc_security_group_ids = ["sg-0780815f55104be8a"]

  tags = {
    Name    = "Dove-Instance"
    Project = "Dove"
  }

  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }
  # provisioner "remote_exec" {
  #   inline = [
  #     "chmod u+x /tmp/web.sh",
  #     "sudo /tmp/web.sh"
  #   ]
  # }
  connection {
    user        = var.USER
    private_key = file(var.PRIV_KEY_PATH)
    host        = self.public_ip
  }
}


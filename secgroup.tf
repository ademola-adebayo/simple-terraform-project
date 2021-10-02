resource "aws_security_group" "dove-bean-elb-SG" {
  name        = "dove-bean-elb-SG"
  description = "Security group for bean-elb"
  vpc_id      = aws_vpc.dove.id

  egress = [{
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 1
    protocol    = "-1"
    self        = false
  }]

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "dove-bastion-SG" {
  name        = "dove-bastion-SG"
  description = "Security group for bastion host ec2 instance"
  vpc_id      = aws_vpc.dove.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.MYIP]
  }
}

resource "aws_security_group" "dove-prod-ec2-SG" {
  name        = "dove-prod-ec2-SG"
  description = "Security group for beanstalk instance"
  vpc_id      = aws_vpc.dove.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dove-bastion-SG.id]
  }
}

resource "aws_security_group" "dove-backend-SG" {
  name        = "dove-backend-SG"
  description = "Security group for RDS, active mq, elastic cache"
  vpc_id      = aws_vpc.dove.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.dove-prod-ec2-SG.id]
  }
}

resource "aws_security_group_rule" "sec_group_allow_itself" {
  tpe                      = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dove-backend-SG.id
  source_security_group_id = aws_security_group.dove-backend-SG.id
}

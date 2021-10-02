variable "aws_REGION" {
  default = "us-east-2"
}

variable "environment" {
  type    = string
  default = "Development"
}
variable "Zone1" {
  default = "us-east-2a"
}

variable "Zone2" {
  default = "us-east-2b"
}

variable "Zone3" {
  default = "us-east-2c"
}

variable "AMIS" {
  type = map(any)
  default = {
    us-east-2 = "ami-03657b56516ab7912"
    us-east-1 = "ami-0947d2ba12ee1ff75"
  }
}

variable "PRIV_KEY_PATH" {
  default = "dove-inst_keys"
}

variable "PUB_KEY_PATH" {
  default = "dove-inst_keys.pub"
}

variable "USERNAME" {
  default = "ubuntu"
}

variable "MYIP" {
  default = "90.197.38.142/32"
}

variable "activeMQUser" {
  default = "rabbit"
}

variable "activeMQPass" {
  default = "Gr33n@rabbit4567"
}

variable "dbuser" {
  default = "admin"
}

variable "dbpass" {
  default = "admin123"
}

variable "dbname" {
  default = "accounts"
}

variable "instance_count" {
  default = "1"
}

variable "vpc_NAME" {
  default = "dove-VPC"
}
variable "cidr_blocks" {
  description = "cidr blocks"
  type = list(string)
}
variable "vpc_CIDR" {
  default = "172.21.0.0/16"
}

variable "pub_Sub-1-CIDR" {
  default = "172.21.1.0/24"
}

variable "pub_Sub-2-CIDR" {
  default = "172.21.2.0/24"
}

variable "pub_Sub-3-CIDR" {
  default = "172.21.3.0/24"
}

variable "priv_Sub-1-CIDR" {
  default = "172.21.4.0/24"
}

variable "priv_Sub-2-CIDR" {
  default = "172.21.5.0/24"
}

variable "priv_Sub-3-CIDR" {
  default = "172.21.6.0/24"
}

variable "REGION" {
  default = "us-east-2"
}
variable "ZONE1" {
  default = "use-east-2a"
}

variable "ZONE2" {
  default = "use-east-2b"
}

variable "ZONE3" {
  default = "use-east-2c"
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

variable "USER" {
  default = "ubuntu"
}


variable "region" {
  default = "us-west-1"
}

#Dinoct aws user
#variable "access_key" {
#  default = "AKIAXORBA3TLDIV3U4MC"
#}

#variable "secret_key" {
#  default = "6UxErlTzArx6Oo+d6CiXF5A1rIEsKmvGjKz3an3z"
#}

#My test user
variable "access_key" {
  default = "AKIA3XRCSNIZO7O7T6XE"
}

variable "secret_key" {
  default = "ohejzZAV3LtqDTqri/UOC+iBfEjzHmFlrI9a2Jjr"
}

variable "az_1" {
  default = "us-west-1a"
}

variable "az_2" {
  default = "us-west-1b"
}

variable "mgmt_vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "mgmt_pubsub1" {
  default = "10.0.1.0/24"
}

variable "mgmt_pubsub2" {
  default = "10.0.2.0/24"
}

variable "mgmt_pvtsub1" {
  default = "10.0.3.0/24"
}

variable "mgmt_pvtsub2" {
  default = "10.0.4.0/24"
}

variable "dev_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "dev_pvtsub1" {
  default = "10.1.1.0/24"
}

variable "dev_pvtsub2" {
  default = "10.1.2.0/24"
}

variable "prod_vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "prod_pvtsub1" {
  default = "10.2.1.0/24"
}

variable "prod_pvtsub2" {
  default = "10.2.2.0/24"
}
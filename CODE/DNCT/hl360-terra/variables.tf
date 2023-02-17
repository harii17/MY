
variable "region" {
  default = "us-west-1"
}

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


variable "prod_vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "prod_pubsub1" {
  default = "10.1.1.0/24"
}

variable "prod_pubsub2" {
  default = "10.1.2.0/24"
}

variable "prod_pvtsub1" {
  default = "10.1.3.0/24"
}

variable "prod_pvtsub2" {
  default = "10.1.4.0/24"
}

variable "prod_pvtsub_db1" {
  default = "10.1.5.0/24"
}

variable "prod_pvtsub_db2" {
  default = "10.1.6.0/24"
}

####

variable "database-instance-class" {
    default = "db.t3.2xlarge"
    description = "DB instance type"
    type = string
}

variable "allocated_storage" {
    default = "100"
    type = string
}

variable "multi-az-deployment" {
    default = "true"
    description = "multi az deployment"
    type = bool
}

variable "database-instance-identifier" {
    default = "testhl360productiondb"
    description = "DB instance name"
    type = string
}

variable "dbusername" {
    default = "admin"
    description = "Username"
    type = string
}

variable "dbpass" {
    default = "Q9xWlepHw1Mru2DTeWUN"
    description = "Password"
    type = string
}

###

variable "alb_log_prefix" { default = "alb-log" }
variable "alb_account_id" { default = "797873946194" }

###

variable "alb_bucket_name" { default = "test-hl360-alb-bucket" }

###

variable "common_tags" {
  type = map
  default = {
    Stack   = "test-hl360" 
  }
}

###

variable "web-type" {
  type = map
  default = {
    ami   = "ami-0729e439b6769d6ab"
    type  = "t2.micro"
    }
}   

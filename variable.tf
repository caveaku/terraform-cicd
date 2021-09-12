variable "ami_id" {
default = "ami-0d5eff06f840b45e9"

}

variable "instance_type" {
default = "t2.micro"
  
}

variable "availability_zone" {
  default = "us-east-1a"

}

variable "vpc_cidr" {

default = "10.0.0.1.0/16"
  
}

variable "pubsubnet_cidr" {
    default = "10.0.1.0/24"
  
}

variable "privsubnet_cidr" {
    default = "10.0.2.0/24"
  
}

variable "idle_timeout" {
    default = "400"
  
}

variable "connection_draining_timeout" {
    default = "400"
  
}

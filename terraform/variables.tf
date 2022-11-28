variable "vpc_cidr" {
  type = string
}

# Type of AWS EC2 instance
variable "main_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "main_vol_size" {
  type    = number
  default = 8
}

variable "main_instance_count" {
  type    = number
  default = 1
}

variable "key_name" {
  type = string
}

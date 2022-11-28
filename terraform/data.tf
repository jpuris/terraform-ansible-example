# AWS region
data "aws_region" "current" {}

# Gets the public IPv4 address where tf is run
data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}

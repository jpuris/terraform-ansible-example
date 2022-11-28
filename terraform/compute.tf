locals {
  public_key_path = pathexpand("~/.ssh/id_rsa.pub")
}

# EC2 Image to be used
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Random number to append to resource tags
resource "random_id" "demo_node_id" {
  count       = var.main_instance_count
  byte_length = 2
}

# The public SSH to be added to the EC2 instance
resource "aws_key_pair" "demo_main_pubkey" {
  key_name   = var.key_name
  public_key = file(local.public_key_path)
}

# EC2 instance
resource "aws_instance" "demo_main" {
  count                  = var.main_instance_count
  instance_type          = var.main_instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.demo_main_pubkey.id
  vpc_security_group_ids = [aws_security_group.demo_security_group.id]
  subnet_id              = aws_subnet.demo_public_subnet[count.index].id
  root_block_device {
    volume_size = var.main_vol_size
  }
  tags = {
    Name = "demo_main-${random_id.demo_node_id[count.index].dec}"
  }
  # After instance has been created, add the instances public DNS entry to Ansible hosts file
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${self.id} --region ${data.aws_region.current.name} && printf '${self.public_dns}' >> ../ansible/hosts"
  }
  # After instance has been destroyed, remove the public DNS entry from Ansible hosts file
  provisioner "local-exec" {
    when    = destroy
    command = "gsed -i '/${self.public_dns}/d' ../ansible/hosts"
  }
}

# Run Ansible the EC2 Setup playbook with the below RSA private key
resource "null_resource" "ec2_setup" {
  depends_on = [
    aws_instance.demo_main
  ]
  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible/hosts --key-file $HOME/.ssh/id_rsa ../ansible/ec2_setup.yml"
  }
}

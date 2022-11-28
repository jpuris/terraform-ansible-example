## About The Project

This mini project 
Deploy an AWS EC2 instance with Grafana, Prometheus stack

## Getting Started

### Prerequisites

- AWS Account
- Linux or MacOS shell
- Python 3.8 or newer
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [AWS CLI tools](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

#### SSH key setup

Make sure you've got both the private key and public key ready to be used

```
$HOME/.ssh/id_rsa
$HOME/.ssh/id_rsa.pub
```

One can generate key pair with following command

```
$ ssh-keygen
```

More details at [ssh.com](https://www.ssh.com/academy/ssh/keygen)

#### AWS CLI profile

Make sure to have a valid AWS CLI profile set up named `terransible`

```
$ cat $HOME/.aws/credentials
[terransible]
aws_access_key_id = CHANGE-ME
aws_secret_access_key = CHANGE-ME
region = CHANGE-ME
```

### Usage

#### Github repository
Clone the repository

```
git clone git@github.com:jpuris/terraform-ansible-example.git
```

#### Terraform Plan

Run the terraform plan

```
$ cd terraform
$ terraform init
$ terraform plan
```

#### Deploying the infrastructure

Apply the terraform infrastructure

```
$ terraform apply
```

#### Accessing the created resources

SSH into EC2

``` 
$ echo "ssh ubuntu@`grep aws ../ansible/hosts` -i ~/.ssh/id_rsa"
```

Grafana URL

```
$ echo "`grep aws ../ansible/hosts`:3000"
```

Prometheus URL

```
$ echo "`grep aws ../ansible/hosts`:9090"
```

#### Cleanup

Remove the created infrastructure

```
$ terraform destroy
```

## License

Distributed under the MIT License. See [LICENSE.txt](LICENSE.txt) for more information.

## Acknowledgments

* [Udemy course, DevOps in the Cloud with Terraform, Ansible, and Jenkins](https://www.udemy.com/course/devops-in-the-cloud/)
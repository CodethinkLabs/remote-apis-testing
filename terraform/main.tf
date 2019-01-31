variable "ssh_key_name" {}

# Configure aws provider
provider "aws" {
  region = "eu-west-1"
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "ami_linux" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*",
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.10.0"

  name        = "example"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "ec2-client" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.13.0"

  instance_count = "${var.clients_number}"

  name                        = "client-bbb"
  ami                         = "${data.aws_ami.ami_linux.id}"
  instance_type               = "${var.clients_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  placement_group             = "placement_group_1"

  root_block_device = [{
    volume_type = "gp2"
    volume_size = 20
  }]
}

module "ec2-frontend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.13.0"

  instance_count = "${var.frontends_number}"

  name                        = "bbb-frontend"
  ami                         = "${data.aws_ami.ami_linux.id}"
  instance_type               = "${var.frontends_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  placement_group             = "placement_group_1"
}

module "ec2-scheduler" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.13.0"

  instance_count = "${var.schedulers_number}"

  name                        = "bbb-scheduler"
  ami                         = "${data.aws_ami.ami_linux.id}"
  instance_type               = "${var.schedulers_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  placement_group             = "placement_group_1"
}

module "ec2-storage" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.13.0"

  instance_count = "${var.storage_number}"

  name                        = "bbb-storage"
  ami                         = "${data.aws_ami.ami_linux.id}"
  instance_type               = "${var.storage_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  placement_group             = "placement_group_1"

  root_block_device = [{
    volume_type = "gp2"
    volume_size = 200
  }]
}

module "ec2-workers" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "1.13.0"

  instance_count = "${var.workers_number}"

  name                        = "bbb-worker"
  ami                         = "${data.aws_ami.ami_linux.id}"
  instance_type               = "${var.workers_type}"
  key_name                    = "${var.ssh_key_name}"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  placement_group             = "placement_group_1"

  root_block_device = [{
    volume_type = "gp2"
    volume_size = 20
  }]
}

output "clients_public_ips" {
  value = "${module.ec2-client.public_ip}"
}

output "clients_private_ips" {
  value = "${module.ec2-client.private_ip}"
}

output "bbb_frontends_public_ip" {
  value = "${module.ec2-frontend.public_ip}"
}

output "bbb_frontends_private_ip" {
  value = "${module.ec2-frontend.private_ip}"
}

output "bbb_schedulers_public_ip" {
  value = "${module.ec2-scheduler.public_ip}"
}

output "bbb_schedulers_private_ip" {
  value = "${module.ec2-scheduler.private_ip}"
}

output "bbb_storage_public_ip" {
  value = "${module.ec2-storage.public_ip}"
}

output "bbb_storage_private_ip" {
  value = "${module.ec2-storage.private_ip}"
}

output "bbb_workers_public_ip" {
  value = "${module.ec2-workers.public_ip}"
}

output "bbb_workers_private_ip" {
  value = "${module.ec2-workers.private_ip}"
}

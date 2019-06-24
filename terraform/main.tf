//variable "ssh_key_name" {}

terraform {
  required_version = ">= 0.12.0"
}

# Configure aws provider
provider "aws" {
  version = ">= 2.11"
  region  = "eu-west-1"
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "3.0.1"

  name        = "example"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "5.0.0"

  cluster_name              = "k8-cluster-${var.cluster_id}"
  cluster_security_group_id = "module.security_group.this_security_group_id"
  cluster_version           = "1.11"

  subnets = data.aws_subnet_ids.all.ids

  vpc_id = data.aws_vpc.default.id

  worker_groups = [
    {
      instance_type        = var.node_type
      asg_desired_capacity = var.node_min_size
      asg_max_size         = var.node_max_size
      asg_min_size         = var.node_min_size
      ebs_optimized        = var.ebs_optimized
    },
  ]

  worker_security_group_id = module.security_group.this_security_group_id
}


//variable "ssh_key_name" {}

# Configure aws provider
provider "aws" {
  region = "eu-central-1"
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "2.2.1"

  cluster_name              = "k8-cluster-${var.cluster_id}"
  cluster_security_group_id = "${module.security_group.this_security_group_id}"
  cluster_version           = "1.11"

  subnets = "${data.aws_subnet_ids.all.ids}"

  vpc_id = "${data.aws_vpc.default.id}"

  worker_groups = [
    {
      instance_type        = "${var.node_type}"
      asg_desired_capacity = "${var.node_min_size}"
      asg_max_size         = "${var.node_max_size}"
      asg_min_size         = "${var.node_min_size}"
      ebs_optimized        = "${var.ebs_optimized}"
    },
  ]

  worker_security_group_id = "${module.security_group.this_security_group_id}"
}

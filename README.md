# remote-apis-testing

This project contains automation to test all the Remote Execution implementations

The repo is structured in 3 folders:
- terraform/
- terraform2ansible/
- ansible/

## Terraform

The terraform folder have instructions to provision a cluster of machines:

- n client machines

- Buildbarn:
  - 1 frontend machine
  - 1 scheduler machine
  - 1 storage machine
  - n worker machine

Before start be sure you have all the needed access keys (see
https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys):

You have your SSH public key added to your AWS account (In Services -> EC2 -> Network & Security -> key pairs)
You have generated your AWS credentials key pair (you will need the access key and the secret key)
(In Services -> IAM -> Users -> Your user -> Security credentials -> Access keys)

To provision the desired cluster, go to the corresponding folder and first initialize terraform with

```
$ terraform init
```
You need to configure your AWS credentials to be in enviroment variables as explained at
https://www.terraform.io/docs/providers/aws/#environment-variables:
```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```
Then execute the following to actually provision the cluster infrastructure:
```
$ terraform apply
```

You will be asked to provide:

Name of the SSH key to use to deploy in the machines as configured in your AWS account

The defaults would be

- Number of clients           = 0
- Number of frontends         = 1
- Number of schedulers        = 1
- Number of storage           = 1
- Number of workers           = 1
- Instance type for clients   = "c5.large"
- Instance type for frontend  = "c5.large"
- Instance type for scheduler = "c5.large"
- Instance type for storage   = "c5d.2xlarge"
- Instance type for workers   = "c5.4xlarge"

To change the defaults use the -var option (see https://aws.amazon.com/ec2/instance-types/ for instance specs):

```
$ terraform apply -var clients_number=25 -var clients_type="c5.xlarge" -var workers_number=5 -var workers_type="c5n.9xlarge" -var ssh_key_name="jjardon"
```

When you are done with your testing, you can destroy the cluster with:

```
$ terraform destroy
```

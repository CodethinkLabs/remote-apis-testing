## Remote Execution API test suite

This project provides a test suite designed to be an automated and independent 'acid test' for the [Remote Execution API](https://github.com/bazelbuild/remote-apis) clients and server implementations.

Initial targets include:
* [Bazel](https://bazel.build/)
* [Buildbarn](https://github.com/EdSchouten/bazel-buildbarn)
* [BuildGrid](https://gitlab.com/BuildGrid/buildgrid)

Potential additional targets are:
* [RECC](https://gitlab.com/bloomberg/recc)
* [BuildStream](https://gitlab.com/BuildStream/buildstream)
* [BuildFarm](https://github.com/uber/bazel-buildfarm)

The initial aim is to test the latest version of Bazel against the latest versions of Buildbarn and BuildGrid on a continous basis, producing a matrix which could (eventually) look something like the following - over-simplified and hypothetical - example:

| --- | BuildGrid | BuildFarm | Buildbarn |
| -------- | -------- | -------- | -------- | 
| Bazel  | Success | Success | Success |
| BuildStream  | Success | Fail | Success |
| RECC | Fail | Success | Fail |

The initial test will be builds of [Absiel](https://abseil.io/) and [Tensorflow](https://www.tensorflow.org/). This will be achieved using Gitlab CI, terraform and ansible, with cloud-backed infra. See below for details on how to set this up.

As a later step, we may want to develop more granular testing of the API, running through all of the gRPC calls and assessing them against the protocol defined in the API.

The repo is structured in 3 folders:
- terraform/
- terraform2ansible/
- ansible/

### Terraform

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

### ansible

These are a series of ansible playbooks that will
- Deploy a base buildbarn implementation
- Deploy clients that will build the tensorflow project using remote caching

### Usage

```ansible-playbook -i <inventory_file> ansible/<PLAYBOOK>.yml --forks N```

Please follow the `README.md` in the `buildbarn/linux/` folder.

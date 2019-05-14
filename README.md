## Remote Execution API test suite

This project provides a test suite designed to be an automated and independent 'acid test' for the [Remote Execution API](https://github.com/bazelbuild/remote-apis) clients and server implementations. You can find us on slack, feel free to come and chat: please use this [invite link](http://tiny.cc/tihy5y) to join our channel.

Initial targets include:
* [Bazel](https://bazel.build/)
* [Buildbarn](https://github.com/EdSchouten/bazel-buildbarn)
* [Buildgrid](https://gitlab.com/BuildGrid/buildgrid)

Potential additional targets are:
* [RECC](https://gitlab.com/bloomberg/recc)
* [BuildStream](https://gitlab.com/BuildStream/buildstream)
* [BuildFarm](https://github.com/uber/bazel-buildfarm)

The initial aim is to test the latest version of Bazel against the latest versions of Buildbarn and BuildGrid on a continuous basis, producing a matrix which could (eventually) look something like the following - over-simplified and hypothetical - example:

| --- | BuildGrid | BuildFarm | Buildbarn |
| -------- | -------- | -------- | -------- |
| Bazel  | Success | Success | Success |
| BuildStream  | Success | Fail | Success |
| RECC | Fail | Success | Fail |

The initial test will be builds of [Absiel](https://abseil.io/) and [Tensorflow](https://www.tensorflow.org/). This will be achieved using Gitlab CI, terraform and ansible, with cloud-backed infra. See below for details on how to set this up.

As a later step, we may want to develop more granular testing of the API, running through all of the gRPC calls and assessing them against the protocol defined in the API.

## Status

Currently this project tests the latest Abseil against the latest container of Buildbarn.

### Terraform

Terraform deployments can be found in the `terraform/<deployment>` folder.

To provision the desired cluster, go to the corresponding folder and first initialise terraform with:

```
$ terraform init
```
You need to configure your AWS credentials to be in enviroment variables as explained [here](https://www.terraform.io/docs/providers/aws/#environment-variables):

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```
Then execute the following to actually provision the cluster infrastructure:

```
$ terraform apply
```

You can find variables available to edit in  `terrform/buildbarn/variables.tf`.

To change these variables in the command line, use the -var option (see [here](https://aws.amazon.com/ec2/instance-types/) for instance specs):

```
$ terraform apply -var cluster_name=foo
```

When you are done with your testing, you can destroy the cluster with:

```
$ terraform destroy
```

### Kubernetes

Kubernetes deployments can be found in the kubernetes folder. They are
created with the following command:

```
kubectl create -f kubernetes/<deployment>/
```

You can check on the status of your cluster with:

```
kubectl get all --all-namespaces
```

Clients are run as a job in the cluster and can be found in
`kubernetes/jobs/` folder.

To see the logs of a job, you can use for example:

```
kubectl logs jobs/abseil -n buildbarn
```
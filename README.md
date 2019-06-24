## Remote Execution API Test Suite

This project provides a test suite designed to be an automated and independent 'acid test' for the [Remote Execution API](https://github.com/bazelbuild/remote-apis) clients and server implementations. You can find us on slack, feel free to come and chat: please use this [invite link](http://tiny.cc/tihy5y) to join our channel. We welcome contributions, please see our [contributing guide](https://gitlab.com/remote-apis-testing/remote-apis-testing/blob/master/CONTRIBUTING.md).

Initial targets include:
* [Bazel](https://bazel.build/)
* [Buildbarn](https://github.com/buildbarn)
* [Buildfarm](https://github.com/bazelbuild/bazel-buildfarm)
* [Buildgrid](https://gitlab.com/BuildGrid/buildgrid)

Potential additional targets are:
* [RECC](https://gitlab.com/bloomberg/recc)
* [BuildStream](https://gitlab.com/BuildStream/buildstream)
* [BuildFarm](https://github.com/uber/bazel-buildfarm)

The initial aim is to test the latest version of Bazel against the latest versions of Buildbarn, Buildfarm and BuildGrid on a continuous basis, producing a compatibility matrix

The initial test will be builds of [Abseil](https://github.com/abseil) and [Bazel](https://github.com/bazelbuild/bazel). This will be achieved using Gitlab CI, Terraform and Kubernetes with AWS.

As a later step, we may want to develop more granular testing of the API, running through all of the gRPC calls and assessing them against the protocol defined in the API.


## Status

This shows a build of Abseil with Bazel against three remote execution implementations.

|             | BuildGrid             | Buildfarm             | Buildbarn             |
| ----------- | --------------------- | --------------------- | --------------------- |
| Bazel       | ![][abseil-buildgrid] | ![][abseil-buildfarm] | ![][abseil-buildbarn] |
| BuildStream | TBA                   | TBA                   | TBA                   |
| RECC        | TBA                   | TBA                   | TBA                   |

[abseil-buildgrid]: https://gitlab.com/remote-apis-testing/remote-apis-testing/builds/artifacts/master/raw/public/buildgrid-deployed.svg?job=pages
[abseil-buildfarm]: https://gitlab.com/remote-apis-testing/remote-apis-testing/builds/artifacts/master/raw/public/buildfarm-deployed.svg?job=pages
[abseil-buildbarn]: https://gitlab.com/remote-apis-testing/remote-apis-testing/builds/artifacts/master/raw/public/buildbarn-deployed.svg?job=pages


## Timing

This shows a build of Bazel with Bazel to produce the following timing information.

|                      | CAS        | No. Workers | Concurrency per worker |
| -------------------- | ---------- | ----------- | ---------------------- |
| ![][bazel-buildgrid] | In memory  | 1           | 1                      |
| ![][bazel-buildfarm] | In memory  | 1           | 4                      |
| ![][bazel-buildbarn] | In memory  | 1           | 4                      |

[bazel-buildgrid]: https://gitlab.com/remote-apis-testing/remote-apis-testing/builds/artifacts/master/raw/public/buildgrid-time.svg?job=pages
[bazel-buildfarm]: https://gitlab.com/remote-apis-testing/remote-apis-testing/builds/artifacts/master/raw/public/buildfarm-time.svg?job=pages
[bazel-buildbarn]: https://gitlab.com/remote-apis-testing/remote-apis-testing/builds/artifacts/master/raw/public/buildbarn-time.svg?job=pages


### Terraform

Terraform deployments can be found in the `terraform/` folder.

To provision the desired cluster, go to the corresponding folder and first initialise terraform with:

```
$ terraform init
```
You need to configure your AWS credentials to be in environment variables as explained [here](https://www.terraform.io/docs/providers/aws/#environment-variables):

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
```
Then execute the following to actually provision the cluster infrastructure:

```
$ terraform apply
```

You can find variables available to edit in  `terrform/variables.tf`.

To change these variables in the command line, use the -var option (see [here](https://aws.amazon.com/ec2/instance-types/) for instance specs):

```
$ terraform apply -var cluster_name=foo
```

When you are done with your testing, you can destroy the cluster with:

```
$ terraform destroy
```

### Kubernetes

Kubernetes deployments can be found in the Kubernetes folder. They are
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

## Local Testing

You can test changes to the Kubernetes deployments locally (avoiding the
need for a cloud provider) with [minikube](https://github.com/kubernetes/minikube).
Note that you'll need at least 4GB of RAM available to your cluster,
which can be achieved with the following command:

```
minikube start --vm-driver kvm2 --memory 4096
```

Assuming you already have `kubectl` installed, this command will also
configure it to use your minikube cluster. After this you can use `kubectl`
commands as described above against your cluster to test your changes as
needed.

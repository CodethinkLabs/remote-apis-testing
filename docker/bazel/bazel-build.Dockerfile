FROM ubuntu:18.04

env VERSION=0.24.1
RUN apt update && apt install -yq pkg-config zip g++ zlib1g-dev unzip python # all was installed in my case
RUN apt install -yq curl
RUN curl -L "https://github.com/bazelbuild/bazel/releases/download/$VERSION/bazel-$VERSION-installer-linux-x86_64.sh" -o bazel-$VERSION-installer-linux-x86_64.sh
RUN chmod +x bazel-$VERSION-installer-linux-x86_64.sh
RUN ./bazel-$VERSION-installer-linux-x86_64.sh --user

RUN apt install -yq git

WORKDIR /src

COPY bazel-build-wrapper /bin/bazel-build-wrapper
COPY bazelrc /src/bazelrc
COPY workspace /src/workspace

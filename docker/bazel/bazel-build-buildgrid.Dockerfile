FROM debian:buster


RUN apt update && apt install -yq git openjdk-11-jdk \
    curl gnupg # For curl | apt-key to work

RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt testing jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
RUN apt update && apt -yq install bazel


RUN apt install -yq git clang

WORKDIR /src

COPY bazel-build-wrapper-host /bin/bazel-build-wrapper
COPY bazelrc-host /src/bazelrc
COPY workspace-host /src/workspace

FROM ubuntu:18.04


RUN apt update && apt install -yq git openjdk-8-jdk \
    curl gnupg # For curl | apt-key to work

RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt testing jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
RUN apt update && apt -yq install bazel


RUN apt install -yq git
RUN apt install -yq python-pip
RUN pip install numpy

WORKDIR /src

COPY bazel-build-wrapper /bin/bazel-build-wrapper
COPY bazelrc /src/bazelrc
COPY workspace /src/workspace

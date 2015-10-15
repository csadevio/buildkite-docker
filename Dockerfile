#FROM phusion/baseimage
FROM phusion/passenger-full
ENV PATH_DATA /data
ENV PATH_BUILD /build
ENV GITHUB_TOKEN unknown
ENV BUILDKITE_AGENT_TOKEN unknown

MAINTAINER "Christian Sakshaug" <christian@csadevio.net>

RUN mkdir -p $PATH_BUILD
RUN mkdir -p $PATH_DATA

RUN echo deb https://apt.buildkite.com/buildkite-agent stable main > /etc/apt/sources.list.d/buildkite-agent.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 32A37959C2FA5C3C99EFBC32A79206696452D198

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y vim
RUN apt-get install -y git
RUN apt-get install -y git-flow
RUN apt-get install -y buildkite-agent

WORKDIR $PATH_BUILD
ADD start.sh start.sh
RUN chmod 755 start.sh

WORKDIR /usr/src

# Install confd
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64
RUN mv confd-0.10.0-linux-amd64 /usr/local/bin/confd
RUN chmod 755 /usr/local/bin/confd

# Install etcd
RUN wget https://github.com/coreos/etcd/releases/download/v2.2.0/etcd-v2.2.0-linux-amd64.tar.gz
RUN tar -zxvf etcd-v2.2.0-linux-amd64.tar.gz
WORKDIR /usr/src/etcd-v2.2.0-linux-amd64
RUN mv etcd /usr/local/bin
RUN mv etcdctl /usr/local/bin
RUN chmod 755 /usr/local/bin/etcd
RUN chmod 755 /usr/local/bin/etcdctl

# Cleanup
RUN rm -rf /usr/src/*

VOLUME $PATH_DATA

WORKDIR $PATH_BUILD

CMD ["./start.sh"]

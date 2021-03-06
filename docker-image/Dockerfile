# install cfssl
FROM golang:1.12 as builder
WORKDIR /go/src/github.com/
RUN go get -u github.com/cloudflare/cfssl/cmd/...

# main workshop container
FROM ubuntu:18.04

COPY --from=builder /go/bin/* /usr/local/bin/

# Install tools:
RUN apt-get update -qq && \
  apt-get install -qqy --no-install-recommends \
    apt-transport-https \
    bc \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    openssh-client \
    uuid \
    vim \
    wget \
  && rm -rf /var/lib/apt/lists/*


ARG YQ_VERSION=2.3.0
RUN wget -q https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64 -O /bin/yq && \
  chmod +x /bin/yq
RUN yq --version

ARG HELM_VERSION=2.12.3
RUN wget -q https://storage.googleapis.com/kubernetes-helm/helm-v$HELM_VERSION-linux-amd64.tar.gz && \
  tar -zxvf helm-v$HELM_VERSION-linux-amd64.tar.gz && \
  mv linux-amd64/helm /bin/helm && \
  rm -f helm-v$HELM_VERSION-linux-amd64.tar.gz && \
  rm -rf linux-amd6

ARG KUBE_VERSION=1.14.1
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kubectl -O /bin/kubectl && \
  chmod +x /bin/kubectl

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update -qq && apt-get install -qqy google-cloud-sdk --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/gkeauto

WORKDIR /usr/gkeauto
COPY *.sh /usr/gkeauto/scripts/

# Start the app
CMD ["/bin/bash"]
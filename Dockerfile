ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG GLIBC_VER=2.34-r0
ARG KUBE_LATEST_VERSION=
ARG HELM_BASE_URL="https://get.helm.sh"
ARG HELM_VER=3.7.1

# install glibc
USER root
RUN apk --no-cache --update add bash curl ca-certificates git jq jsonnet terraform nodejs
RUN curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
 && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk \
 && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk \
 && ls -la \
 && apk add --no-cache glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk

# install awscliv2
RUN case $(uname -m) in \
        x86_64) ARCH=x86_64; ;; \
        aarch64) ARCH=aarch64; ;; \
        *) echo "Error: unsupported arch." > /dev/stderr; exit 1; ;; \
    esac \
 && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-${ARCH}.zip -o awscliv2.zip \
 &&   unzip -q awscliv2.zip \
 && aws/install \
 && rm awscliv2.zip

# kubectl
RUN case $(uname -m) in \
        x86_64)  ARCH=amd64; ;; \
        armv7l)  ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x)   ARCH=s390x; ;; \
        *) echo "Error: unsupported arch." > /dev/stderr; exit 1; ;; \
    esac \
 && curl -sL https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Helm
RUN case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "Error: unsupported arch." > /dev/stderr; exit 1; ;; \
    esac \
 && curl -sL ${HELM_BASE_URL}/helm-v${HELM_VER}-linux-${ARCH}.tar.gz | tar xz \
 && mv linux-${ARCH}/helm /usr/bin/helm \
 && chmod +x /usr/bin/helm \
 && rm -rf linux-${ARCH} \

USER user

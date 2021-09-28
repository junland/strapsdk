FROM fedora:latest

RUN groupadd -r builder -g 433 && \
    useradd -m -d /source -u 431 -r -g builder -s /sbin/nologin -c "Container build user" builder

USER root

RUN dnf group install 'Development Tools' -y && \
    dnf install vim nano wget curl bzip2 xz -y && \
    dnf install gcc gcc-c++ automake bison cmake gettext-devel ldc meson ninja-build texinfo -y && \
    dnf clean all

USER builder

COPY . /source

WORKDIR /source
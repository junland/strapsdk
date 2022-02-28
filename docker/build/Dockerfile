FROM fedora:35

USER root

RUN dnf upgrade -y && \
    dnf group install "C Development Tools and Libraries" "Development Tools" -y && \
    dnf install bzip2 curl findutils patch diffutils nano vim wget xz hostname sudo bash dash zsh -y && \
    dnf install acl autoconf-archive automake bc bison bison-devel byacc cmake expat-devel expect flex-devel file g++ gawk gcc gcc-c++ gettext-devel \
                ldc libattr-devel m4 make meson ncurses-devel ninja-build procps-ng perl-ExtUtils-ParseXS perl-XML-Parser python3 rsync texinfo langpacks-en \
                gawk-all-langpacks glibc-all-langpacks glibc-locale-source -y && \
    dnf clean all

RUN groupadd builder && \
    useradd -s /bin/bash -g builder -m -k /dev/null -d /source -c "Container build user" builder && \
    echo "builder:builder" | chpasswd && \
    echo "builder ALL = NOPASSWD : ALL" >> /etc/sudoers && \
    echo 'Defaults env_keep += "LC_ALL PATH STRAPY_BUILD_JOBS"' >> /etc/sudoers
    
RUN echo "umask 022" >> /source/.profile && echo "umask 022" >> /source/.bashrc && \
    echo "set +h" >> /source/.profile && echo "set +h" >> /source/.bashrc

COPY . /source

RUN chown builder -Rv /source && chmod +x -v /source/build.sh /source/core.functions

USER builder

ENV STRAPY_BUILD_JOBS 2

WORKDIR /source

ENTRYPOINT [ "/source/build.sh" ]
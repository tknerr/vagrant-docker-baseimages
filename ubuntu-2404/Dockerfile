FROM ubuntu:24.04

ENV DEBIAN_FRONTEND noninteractive

# install common dependencies
RUN apt-get update && apt-get install -y \
    wget \
    locales \
    curl \
    lsb-release \
    sudo \
    python3

RUN apt-get download openssh-server && \
    mv openssh-server_* openssh-server.deb && \
    dpkg-deb -R openssh-server.deb openssh-server && \
    sed -i 's/^[[:space:]]*systemctl.*/echo "Skipping systemd configuration"/' openssh-server/DEBIAN/postinst && \
    dpkg-deb -b openssh-server openssh-server-updated.deb

RUN dpkg -i openssh-server-updated.deb || apt-get install -f -y && \
    rm -rf openssh-server.deb openssh-server openssh-server-updated.deb

# ensure we have the en_US.UTF-8 locale available
RUN locale-gen en_US.UTF-8

# setup the vagrant user
RUN if ! getent passwd vagrant; then useradd -d /home/vagrant -m -s /bin/bash vagrant; fi \
    && echo vagrant:vagrant | chpasswd \
    && echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /etc/sudoers.d \
    && echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vagrant \
    && chmod 0440 /etc/sudoers.d/vagrant

# add the vagrant insecure public key
RUN mkdir -p /home/vagrant/.ssh \
    && chmod 0700 /home/vagrant/.ssh \
    && wget --no-check-certificate \
    https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub \
    -O /home/vagrant/.ssh/authorized_keys \
    && chmod 0600 /home/vagrant/.ssh/authorized_keys \
    && chown -R vagrant /home/vagrant/.ssh

# don't clean packages, we might be using vagrant-cachier
RUN rm /etc/apt/apt.conf.d/docker-clean

# create the privilege separation directory for sshd
RUN mkdir -p /run/sshd

# run sshd in the foreground
CMD /usr/sbin/sshd -D \
    -o UseDNS=no\
    -o UsePAM=no\
    -o PasswordAuthentication=yes\
    -o PidFile=/tmp/sshd.pid
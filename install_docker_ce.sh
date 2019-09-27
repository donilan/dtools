#!/usr/bin/bash

set -xe

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast


sudo yum install docker-ce -y

sudo mkdir -p /etc/docker
cat << EOF > /tmp/daemon.json
{
  "log-driver": "journald"
}
EOF
sudo mv /tmp/daemon.json /etc/docker/

sudo systemctl start docker
sudo systemctl enable docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

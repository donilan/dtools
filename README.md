# dtools
some personal tools

## init emacs

``` bash
curl -sSL https://raw.githubusercontent.com/donilan/dtools/master/init_emacs.sh  | bash
```

## install docker

``` bash
curl -sSL https://raw.githubusercontent.com/donilan/dtools/master/install_docker_ce.sh | bash
```

## Install Laster linux kernel for centos

``` bash
curl -sSL https://raw.githubusercontent.com/donilan/dtools/master/centos_latest_kernel.sh | sudo bash
```

## Enable BBR

``` bash
curl -sSL https://raw.githubusercontent.com/donilan/dtools/master/enable_bbr.sh | sudo bash
```

## OSX tools
batch reduce image size
``` bash
sips -Z 500 *.jpg
```

## time sync
```bash
sudo yum install ntp -y
sudo systemctl start ntpd
sudo systemctl enable ntpd
```

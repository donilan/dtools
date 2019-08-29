#!/usr/bin/env bash

set -xe

if [ ! -f /usr/local/bin/traefik ] ; then
    sudo yum install curl -y
    sudo curl -L https://github.com/containous/traefik/releases/download/v1.7.14/traefik_linux-amd64 -o /usr/local/bin/traefik
fi

sudo chown root:root /usr/local/bin/traefik
sudo chmod 755 /usr/local/bin/traefik
sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik

if [ -z "$(id -u traefik)" ] ; then
    sudo groupadd traefik
    sudo useradd \
	-g traefik --no-user-group \
	--home-dir /var/www --no-create-home \
	--shell /usr/sbin/nologin \
	--system --uid 321 traefik
fi

sudo mkdir -p /etc/traefik
sudo mkdir -p /etc/traefik/acme
sudo chown -R root:root /etc/traefik
sudo chown -R traefik:traefik /etc/traefik/acme


cat <<EOF > /tmp/traefik.toml
logLevel = "INFO"

defaultEntryPoints = ["https", "http"]

[entryPoints]
  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
    entryPoint = "https"
  [entryPoints.https]
  address = ":443"
    [entryPoints.https.tls]

[acme]

email = ""
storage = "/etc/traefik/acme/acme.json"
entryPoint = "https"

[acme.tlsChallenge]

[[acme.domains]]
  main = "$HOSTNAME"

[file]

[backends]
  [backends.backend1]
    [backends.backend1.servers.server1]
    url = "http://127.0.0.1:3000"
    weight = 10

[frontends]
  [frontends.frontend1]
  backend = "backend1"
    [frontends.frontend1.routes.test_1]
    entrypoints = ["http","https"]
    rule = "Host:$HOSTNAME"
    passHostHeader = true

[accessLog]
EOF
sudo cp /tmp/traefik.toml /etc/traefik/
sudo chown root:root /etc/traefik/traefik.toml
sudo chmod 644 /etc/traefik/traefik.toml




cat <<EOF > /tmp/traefik.service
[Unit]
Description=traefik proxy
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Restart=on-abnormal

; User and group the process will run as.
User=traefik
Group=traefik

; Always set "-root" to something safe in case it gets forgotten in the traefikfile.
ExecStart=/usr/local/bin/traefik --configfile=/etc/traefik/traefik.toml

; Limit the number of file descriptors; see man systemd.exec for more limit settings.
LimitNOFILE=1048576

; Use private /tmp and /var/tmp, which are discarded after traefik stops.
PrivateTmp=true
; Use a minimal /dev (May bring additional security if switched to 'true', but it may not work on Raspberry Pi's or other devices, so it has been disabled in this dist.)
PrivateDevices=false
; Hide /home, /root, and /run/user. Nobody will steal your SSH-keys.
ProtectHome=true
; Make /usr, /boot, /etc and possibly some more folders read-only.
ProtectSystem=full
; … except /etc/ssl/traefik, because we want Letsencrypt-certificates there.
;   This merely retains r/w access rights, it does not add any new. Must still be writable on the host!
ReadWriteDirectories=/etc/traefik/acme

; The following additional security directives only work with systemd v229 or later.
; They further restrict privileges that can be gained by traefik. Uncomment if you like.
; Note that you may have to add capabilities required by any plugins in use.
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF


sudo cp /tmp/traefik.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/traefik.service
sudo chmod 644 /etc/systemd/system/traefik.service
sudo systemctl daemon-reload
# sudo systemctl start traefik.service

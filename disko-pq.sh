#!/usr/bin/env bash

set -euxo pipefail
# NOTE: replace with root if using offical iso
nix run github:nix-community/nixos-anywhere/main -- --option pure-eval "false" --flake .#pq-vpn $(id -un)@pq.furrytel.me --no-substitute-on-destination


# instructions:
# go to pq.hosting
# login
# virtual private servers
# select three dot menu next to server -> click go to panel
# on panel select three dot menu -> mount iso image

# WITH PATCHED ISO
# select public url, enter https://mkg20001.io/tmp/pq.iso
# wait until machine boots (ping ip)
# run disk-pq.sh

# BUILD & UPLOAD PATCHED ISO
# nix build .#pq-iso
# rsync result/*/*iso helium.y.mkg20001.io:/srv/www/pq.iso --progress

# WITH REGULAR NIXOS ISO
# select public url, enter https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso
# wait
# go to vnc
# $ sudo bash
# $ loadkeys de
# $ systemctl stop dhcpcd
# $ ip a a 45.144.31.173/24 dev ens3
# $ ip r a default via 45.144.31.1
# $ nano /etc/resolv.conf -> add 1.1.1.1
# $ nix-shell -p ssh-import-id
# $ ssh-import-id gh:YOURGH
# then run disko-pq.sh

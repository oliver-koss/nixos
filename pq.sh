#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#pq-vpn --use-substitutes --target-host 45.144.31.173 --use-remote-sudo switch

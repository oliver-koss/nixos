#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#pq-vpn --use-substitutes --target-host pq.furrytel.me --use-remote-sudo switch

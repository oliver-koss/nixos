#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#oliver-server --use-substitutes --target-host nixos-server.oliver-koss.at --use-remote-sudo switch

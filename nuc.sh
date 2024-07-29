#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#oliver-nuc --use-substitutes --target-host nuc.ygg.oliver-koss.at --use-remote-sudo switch

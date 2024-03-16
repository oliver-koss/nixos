#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#oliver-nuc --use-substitutes --target-host nuc.oliver-koss.at --use-remote-sudo switch

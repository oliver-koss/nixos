#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#oliver-pi --use-substitutes --build-host $(id -un)@aarch64.mkg20001.io --use-remote-sudo --target-host $(id -un)@pi.oliver-koss.at switch

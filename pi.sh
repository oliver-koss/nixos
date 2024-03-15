#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#oliver-pi --use-substitutes --build-host $(id -un)@aarch64.mkg20001.io --target-host root@pi.oliver-koss.at switch

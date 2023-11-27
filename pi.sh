#!/bin/sh

set -euxo pipefail

nixos-rebuild --flake .#oliver-pi --build-host oliver@aarch64.mkg20001.io --target-host root@pi.oliver-koss.at switch

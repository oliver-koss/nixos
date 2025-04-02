#!/bin/bash

set -euxo pipefail

NEWV4="$1"
NEWV6="$2"

OLDV4=$(cat pq/values.nix  | grep ipv4 | grep -o "[0-9][0-9][0-9.]*")
OLDV6=$(cat pq/values.nix  | grep ipv6 | grep -o "[0-9][0-9a-f][0-9a-f][0-9a-f:]*")

SELF=$(dirname $(readlink -f "$0"))

replace()  {
  find "$SELF/pq" "$SELF/torrent" -type f -exec sed -i "s|$1|$2|g" {} \;
}

replace "$OLDV4" "$NEWV4"
replace "$OLDV6" "$NEWV6"

#! /bin/sh

set -euxo pipefail

n() {
  ip netns exec tz /bin/sh -c "$1"
}

case "$1" in
  up)
    ip l d tzouter || true
    ip netns delete tz || true

    ip netns add tz
    ip link add dev tzouter type veth peer name tzinner netns tz
      ip a a fd07::1/64 dev tzouter
      ip a a 10.0.7.1/24 dev tzouter
      ip l s tzouter up

    n "ip a a fd07::2/64 dev tzinner"
      n "ip a a 10.0.7.2/24 dev tzinner"
      n "ip l s tzinner up"
      # NOTE: please leave default rotes disabled
      # this will otherwise lead to leaks when vpn fails in a way
      # that's not caught by wg-quick
      # n "ip r a dev tzinner default via 10.0.7.1"
      # n "ip -6 r a dev tzinner default via fd07::1"
      n "ip r a dev tzinner 192.168.178.1 via 10.0.7.1"
      n "ip -6 r a dev tzinner fd83:e647:3f34:0::/64 via fd07::1" # local
      n "ip -6 r a dev tzinner 2a02:1748:dd4e:2040::/60 via fd07::1" # local
      n "ip -6 r a dev tzinner 2a09:7c47:0:15::1 via fd07::1" # pq

    n "ip a a 127.0.0.1/8 dev lo"
      n "ip a a ::1/128 dev lo"

# TODO: create wg interface in main ns and move to tz ns
# ref: https://www.wireguard.com/netns/#the-new-namespace-solution
    n "wg-quick up /var/pq.conf"
	;;
  down)
    ip l d tzouter
    ip netns delete tz
	;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
  ;;
esac

exit 0

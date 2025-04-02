#! /bin/sh

set -euxo pipefail

n() {
  ip netns exec tz /bin/sh -c "$1"
}

case "$1" in
  up)
    ip l d tzouter || true
    ip l d pq || true
    ip -n tz l d pq || true
    ip netns delete tz || true

    ip netns add tz
    # we still need access to the inside for webserver'n'stuff
    ip link add dev tzouter type veth peer name tzinner netns tz
      ip a a fd07::1/64 dev tzouter
      ip a a 10.0.7.1/24 dev tzouter
      ip l s tzouter up

    ip link add pq type wireguard
    ip link set pq netns tz

    n "ip a a fd07::2/64 dev tzinner"
      n "ip a a 10.0.7.2/24 dev tzinner"
      n "ip l s tzinner up"

    n "ip a a 127.0.0.1/8 dev lo"
      n "ip a a ::1/128 dev lo"

    n "wg setconf pq /var/pq.conf"
    n "ip l s pq up"

    n "ip a a 10.7.0.2/32 dev pq"
      n "ip r r 10.7.0.0/24 dev pq"

    n "ip -6 a a 2a09:7c47:0:4::2/128 dev pq"
      n "ip -6 r r 2a09:7c47:0:4::1/64 dev pq"

    n "ip r a default dev pq"
      n "ip -6 r a default dev pq"
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

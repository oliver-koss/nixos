#! /bin/sh

set -euo pipefail

case "$1" in
  up)
    ip netns add tz
    ip link add dev tzouter type veth peer name tzinner netns tz
      ip a a fd07::1/64 dev tzouter
      ip a a 10.0.7.1/24 dev tzouter
      ip l s tzouter up

    ip netns exec tz /bin/sh -c "ip a a fd07::2/64 dev tzinner"
      ip netns exec tz /bin/sh -c "ip a a 10.0.7.2/24 dev tzinner"
      ip netns exec tz /bin/sh -c "ip l s tzinner up"
      ip netns exec tz /bin/sh -c "ip r a dev tzinner default via 10.0.7.1"
      ip netns exec tz /bin/sh -c "ip -6 r a dev tzinner default via fd07::1"
      ip netns exec tz /bin/sh -c "ip r a dev tzinner 192.168.178.1 via 10.0.7.1"

    ip netns exec tz /bin/sh -c "ip a a 127.0.0.1/8 dev lo"
      ip netns exec tz /bin/sh -c "ip a a ::1/128 dev lo"

    ip netns exec tz /bin/sh -c "wg-quick up /var/pq.conf"
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

{
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users.root = {
          acl = [
            "readwrite #"
          ];
          hashedPassword = "$7$101$/WXUe6AHS9XmM4iW$r1jXiDNpscofTiXqV9eqPb/JDjwahxu3z1EuCcBG95Zs4snRJyCcryFN/lYSZMFNSnqKuhzlxFoKrFFbyPo4tA==";
        };
        users.metrics = {
          acl = [
            "readwrite #"
          ];
          hashedPassword = "$7$101$WQNV+c6isU9d5X4L$clsBotLkGFk6bnXveEH3FR8LwzJL+shLxv0x4ltRelvT8C9l3xhF1uHqUsYi+iPlcoyJQKMTa1NexOCBQP1PeQ==";
        };
      }
    ];
  };
 
  networking.firewall.extraInputRules = ''
    ip saddr { 192.168.178.0/24, 172.17.0.0/16 } tcp dport 1883 accept
  '';
}

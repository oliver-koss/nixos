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
          hashedPassword = "$7$101$PEPmB/n+u2TV4dfK$Lodb7PCCrRx+OWp3ItT/iH4JzjSKnbVCRS8OcfvWRIUkoAR+ra34UOI1SpqljYwRtPa+q2f5SJuFQIbB/yFxcA==";
        };
      }
    ];
  };
 
  networking.firewall.extraInputRules = ''
    ip saddr { 192.168.178.0/24, 172.17.0.0/16 } tcp dport 1883 accept
  '';
}

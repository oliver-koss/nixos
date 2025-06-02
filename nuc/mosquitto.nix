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
          hashedPassword = "$7$101$NJIFIbf0qDLVebfz$juOFMR4I5pAszD5srRUNwsL1GYq61a9grdl8J9NpuXOjE87h+QHHsCOcVLuvSyasomqmwbtW9xrJWzR6ksD+wA==";
        };
      }
    ];
  };
 
  networking.firewall.extraInputRules = ''
    ip saddr { 192.168.178.0/24, 172.17.0.0/16 } tcp dport 1883 accept
  '';
}

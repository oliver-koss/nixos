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
      }
    ];
  };
}

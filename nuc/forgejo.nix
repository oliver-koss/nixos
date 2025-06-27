{
  services.postgresql = {
    enable = true;
    ensureUsers = [{
       name = "forgejo";
         ensureDBOwnership = true;
       }];
     ensureDatabases = [ "forgejo" ];
  };

  services.forgejo = {
    enable = false;
    settings = {
    };
    database = {
      type = "postgresql";
      socket = "/run/postgresql";
      name = "forgejo";
      user = "forgejo";
    };
  };

}

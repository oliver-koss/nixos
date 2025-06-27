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
    enable = true;
    lfs.enable = true;
    settings = {
    };
    database = {
      type = "postgres";
      socket = "/run/postgresql";
      name = "forgejo";
      user = "forgejo";
    };
  };

}

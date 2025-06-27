{
  services.postgresql = {
    enable = true;
    ensureUsers = [{
       name = "forgejo";
         ensureDBOwnership = true;
       }];
     ensureDatabases = [ "forgejo" ];
  };
}

{ pkgs, lib, ...}: {

  services.part-db = {
    enable = true;
    enableNginx = false;
  };
}

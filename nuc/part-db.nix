{ pkgs, lib, ...}: {

  services.part-db = {
    enable = false;
    enableNginx = false;
  };
}

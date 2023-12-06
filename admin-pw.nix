{ lib, ... }:

with lib;

{
  options.default-admin-password = mkOption {
    type = types.str;
    default = "e6489uet4u89erz8ierz8iu";
  };
}

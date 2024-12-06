{ lib, ... }:

with lib;

let
  clientSubmodule = { config, options, key, ... }: {
    options = {
      publicKey = mkOption {
        type = types.str;
      };

      id = mkOption {
        type = types.int;
      };

      portsV4 = mkOption {
        type = types.listOf types.int;
        default = [];
      };
    };
  };
in
{
  options.pq = {
    ipv4 = mkOption {
      type = types.str;
    };
    privateIPv4 = {
      prefix = mkOption {
        default = "10.7.0.";
      };
    };

    ipv6 = {
      prefix = mkOption {
        type = types.str;
        example = "1:2:3:4::";
      };
      suffix = mkOption {
        type = types.str;
        default = "1";
      };
      prefixLength = mkOption {
        default = 64;
      };
    };

    interface = mkOption {
      type = types.str;
    };

    clients = mkOption {
      type = types.attrsOf (types.submodule clientSubmodule);
    };
  };
}

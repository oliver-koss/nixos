{ lib, ... }:

with lib;

{
  mkg.mod.yggdrasil.peers = mkForce [ "tcp://v4.ygg.mkg20001.io:80" "tls://v4.ygg.mkg20001.io:443" "tcp://168.119.72.237:29553" ];
}

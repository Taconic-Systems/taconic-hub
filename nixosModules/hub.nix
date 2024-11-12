{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  system,
  lib,
  ...
}:
with lib;
{

  imports = [ ./admin.nix ];

  config = {
    taconic.admin.enable = true;
  };
  # nginx

  # rsyslog
  # smtp relay
  # dns

  #imports = [ ./configuration.nix ];
  #imports = [ ../common.nix ];

  # search for files in nix pkgs

  # programs.nix-index.enable = true;
}

{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  system,
  lib,
  ...
}:
{

  imports = [
    ./admin.nix
    ./nginx-proxy.nix
    ./wireguard-vpn.nix
    ./log-server.nix
    ./network-monitor.nix
    #./backup-server.nix
  ];

  options = {
    taconic.enable = lib.mkEnableOption "Enable Taconic NixOS modules";
    taconic.internalIp = lib.mkOption { type = lib.types.str; };
    taconic.internalInterface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };
    taconic.externalIp = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
    };
    taconic.externalInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
    };
  };

  config = {

    # each sub-module should be enabled here if it's part of the default set
    taconic.admin.enable = lib.mkDefault true;
    # Force use of nftables
    networking.nftables.enable = true;

  };

  # smtp relay
  # dns

  #imports = [ ./configuration.nix ];
  #imports = [ ../common.nix ];

  # search for files in nix pkgs

  # programs.nix-index.enable = true;
}

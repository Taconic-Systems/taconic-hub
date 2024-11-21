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
    taconic.admin-email = lib.mkOption {
      type = lib.types.str;
      description = "Administrator email, should be a deliverable address.";
    };

    taconic.internalIp = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Our IP address on the internal network";
    };

    taconic.internalInterface = lib.mkOption {
      type = lib.types.str;
      default = "eth0";
      description = "The interface connected to our internal network";
    };

  };

  config = {

    # each sub-module should be enabled here if it's part of the default set
    taconic.admin.enable = lib.mkDefault true;

    # Force use of nftables
    networking.nftables.enable = lib.mkDefault true;

    # ipv6 off by default
    networking.enableIPv6 = lib.mkDefault false;

  };

  # smtp relay
  # dns

}

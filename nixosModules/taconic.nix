{
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
    ./backup-server.nix
    ./backup-client.nix
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

    # each sub-module should be enabled here if it's part of the
    # default set, which should be kept minimal
    taconic.admin.enable = lib.mkDefault true;

    # Force use of nftables
    networking.firewall.enable = true;
    networking.nftables.enable = true;

    # ipv6 off by default
    networking.enableIPv6 = lib.mkDefault false;

  };

  # smtp relay
  # dns

}

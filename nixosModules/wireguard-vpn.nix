{
  inputs,
  config,
  pkgs,
  system,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.taconic.wireguard-vpn;
in
#opt = options.taconic.wireguard-vpn;
{

  options = {
    taconic.wireguard-vpn.enable = mkEnableOption "Enable Taconic Wireguard VPN Server module";
    taconic.wireguard-vpn.externalInterface = mkOption {
      type = types.str;
      example = "eth0";
      default = config.taconic.internalInterface;
      description = "The network interface we will route outbound traffic too.";
    };
    taconic.wireguard-vpn.port = mkOption {
      type = types.port;
      default = 51820;
      description = "The UDP port to listen for incoming wireguard connection on.";
    };
    taconic.wireguard-vpn.serverIP = mkOption {
      type = types.str;
      default = "10.10.10.1/24";
      description = "The IP address and netmask, in CIDR form, for the server's interface on the VPN network.";
    };
    taconic.wireguard-vpn.interface = mkOption {
      type = types.str;
      default = "wg0";
    };
  };

  # Based on https://nixos.wiki/wiki/WireGuard

  config = mkIf cfg.enable {

    # enable NAT

    networking.nat.enable = true;
    networking.nat.externalInterface = cfg.externalInterface;
    networking.nat.internalInterfaces = [ cfg.interface ];

    # allow the inconming UDP packets for WG clients
    networking.firewall = {
      allowedUDPPorts = [ cfg.port ];
    };

    networking.wireguard.interfaces = {

      # "wg0" is the network interface name. You can name the interface arbitrarily.
      wg0 = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ cfg.serverIP ];

        # The port that WireGuard listens to. Must be accessible by the client.
        listenPort = cfg.port;

        # Path to the private key file.
        #
        # Note: The private key can also be included inline via the privateKey option,
        # but this makes the private key world-readable; thus, using privateKeyFile is
        # recommended.
        generatePrivateKeyFile = true;
        privateKeyFile = "/etc/nixos/secrets/wg0.key";
      };
    };
    # quality of life tools
    environment.systemPackages = [
      pkgs.age
      pkgs.wireguard-tools
    ];
  };
}

{ inputs, sops-nix, ... }:
{

  ### start generated hardware-configuration.nix
  imports = [
    sops-nix.nixosModules.sops
    ./hardware-configuration.nix
    inputs.hub.nixosModules.taconic
  ];

  networking.hostName = "example";

  taconic.enable = true;
  taconic.craig.enable = true;
  taconic.admin-email = "craig@taconic.systems";

  taconic.wireguard-vpn.enable = true;
  taconic.wireguard-vpn.port = 61820;
  taconic.wireguard-vpn.serverIP = "10.10.10.1/24";

  # this is the interface closest to the power cable
  taconic.internalInterface = "enp0s31f6";
  taconic.internalIp = "192.168.1.69";

  networking.wireguard.interfaces.wg0.peers = [
    {
      publicKey = "yW8PVCn5oPeH0plqfbO1fwMJX51CdB+qJzhSal0xgik=";
      allowedIPs = [ "10.10.10.2/32" ];
    }
  ];

  services.nginx.virtualHosts."grafana.taconic.systems" = {
    locations."/".proxyPass = "http://grafana";
    listen = [
      {
        addr = "10.10.10.1";
        port = 80;
      }
    ];
  };

  taconic.log-server.enable = true;

  taconic.network-monitor.enable = true;

  # disable all rules
  services.suricata.disabledRules = [ "*" ];
  services.suricata.settings.host-mode = "sniffer-only";

  system.stateVersion = "24.05";

}

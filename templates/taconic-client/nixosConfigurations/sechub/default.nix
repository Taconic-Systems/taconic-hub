{
  inputs,
  sops-nix,
  pkgs,
  ...
}:
{

  imports = [
    # UPDATE
    # You should copy the hardware-configuration.nix from your
    # target system
    ./hardware-configuration.nix
    ./users.nix
    sops-nix.nixosModules.sops
    inputs.hub.nixosModules.taconic
  ];

  networking.hostName = "sechub";

  taconic.enable = true;
  # only if you pay me to manage this machine
  taconic.craig.enable = true;
  taconic.admin-email = "craig@taconic.systems";

  taconic.wireguard-vpn.enable = true;
  taconic.wireguard-vpn.serverIP = "10.10.10.1/24";

  # UPDATE: this is the interface on your internal network
  taconic.internalInterface = "enp0s31f6";
  taconic.internalIp = "192.168.1.69";

  # This allows Taconic System admins to connect to the VPN on this
  # host once you send them your public key and expose the wireguard
  # port (51820) of this host to the internet
  networking.wireguard.interfaces.wg0.peers = [
    {
      publicKey = "yW8PVCn5oPeH0plqfbO1fwMJX51CdB+qJzhSal0xgik=";
      allowedIPs = [ "10.10.10.2/32" ];
    }
  ];

  # install some useful programs
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.git
    pkgs.curl
    pkgs.vim
  ];

  taconic.log-server.enable = true;

  # Turning this on will produce a large volume of netflow logs
  taconic.network-monitor.enable = false;

  # disable all rules
  services.suricata.disabledRules = [ "*" ];
  services.suricata.settings.host-mode = "sniffer-only";

  taconic.backup-server.enable = true;
  taconic.backup-client.enable = true;
  # example for adding ssh access to backup clients to the "bub"
  # backup services
  # services.bub-server.users.bub.keys = ["sshpubkey"];

  system.stateVersion = "24.05";

}

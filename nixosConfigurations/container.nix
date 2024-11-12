{
  inputs,
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{

  boot.isContainer = true;
  networking.hostName = "hubtest";

  nixpkgs.hostPlatform.system = "x86_64-linux";

  imports = [ ../nixosModules/taconic.nix ];

  taconic.enable = true;

  taconic.wireguard-vpn.enable = true;
  taconic.externalIp = "0.0.0.0";
  taconic.externalInterface = "eth0";
  taconic.internalIp = "10.100.0.1";

  taconic.log-server.enable = true;
  taconic.log-server.collectionIp = "10.10.1.33";

  taconic.network-monitor.enable = true;
  taconic.network-monitor.interface = "eth0";

  system.stateVersion = "24.05";
  # search for files in nix pkgs
  # programs.nix-index.enable = true;

}

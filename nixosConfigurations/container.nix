{
  inputs,
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{

  imports = [ ../nixosModules/taconic.nix ];

  boot.isContainer = true;
  networking.hostName = "hubtest";

  #nixpkgs.hostPlatform.system = "x86_64-linux";

  taconic.enable = true;
  taconic.craig.enable = true;
  taconic.admin-email = "craig@taconic.systems";

  taconic.internalInterface = "eth0";
  taconic.internalIp = "10.10.1.33";

  taconic.wireguard-vpn.enable = true;

  taconic.log-server.enable = true;

  taconic.network-monitor.enable = true;

  system.stateVersion = "24.05";
  # search for files in nix pkgs
  # programs.nix-index.enable = true;

}

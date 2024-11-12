{
  inputs,
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{

  networking.hostName = "hubvm";

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

  users.groups.admin = { };
  users.users = {
    admin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "admin";
      group = "admin";
    };
  };

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 3;
      graphics = false;
    };
  };
}

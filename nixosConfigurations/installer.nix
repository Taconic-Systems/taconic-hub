{
  inputs,
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../nixosModules/taconic.nix
  ];

  taconic.enable = true;
  taconic.admin.enable = true;

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJEShO6BZLGkS/+1NWrzgH+UN2sJVp+OeQJxNu0P2O1+AAAABHNzaDo= craig@taconic.systems"
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "24.05";
  # search for files in nix pkgs
  # programs.nix-index.enable = true;

}

{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  system,
  lib,
  ...
}:
with lib;
{
  options = {
    taconic.craig.enable = mkEnableOption "Create an administrative user for Craig Brozefsky <craig@taconic.systems>";
  };
  config = mkIf config.taconic.craig.enable {
    users.users.craig = {
      isNormalUser = true;
      createHome = true;
      description = "Craig Brozefsky";
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
      ];
      packages = with pkgs; [ ];
      openssh.authorizedKeys.keys = [
        # ssh key bound to YubiKey
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJEShO6BZLGkS/+1NWrzgH+UN2sJVp+OeQJxNu0P2O1+AAAABHNzaDo= craig@taconic.systems"
      ];
    };

    # allow user to do nixos-rebuild and other nix operations
    nix.settings = {
      trusted-users = [ "craig" ];
      allowed-users = [ "craig" ];
    };
  };
}

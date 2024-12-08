{
  ...
}:
{
  # users.users.example = {
  #   isNormalUser = true;
  #   createHome = true;
  #   description = "Example User";
  #   extraGroups = [
  #     "wheel" # Enable ‘sudo’ for the user.
  #   ];
  #   openssh.authorizedKeys.keys = [
  #     # ssh key bound to YubiKey
  #     "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJEShO6BZLGkS/+1NWrzgH+UN2sJVp+OeQJxNu0P2O1+AAAABHNzaDo= craig@taconic.systems"
  #   ];
  # };

  # # allow user to do nixos-rebuild and other nix operations
  # nix.settings = {
  #   trusted-users = [ "example" ];
  #   allowed-users = [ "example" ];
  # };
}

{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
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
  cfg = config.taconic.admin;
in
{

  options = {
    taconic.admin.enable = mkEnableOption "Enable Taconic sysadmin access";
  };

  imports = [ ./craig.nix ];

  config = mkIf config.taconic.admin.enable {

    environment.shells = [ pkgs.bashInteractive ];

    nix.gc.automatic = true;
    nix.settings = {

      trusted-users = [ "root" ];
      allowed-users = [ "root" ];
      extra-nix-path = "nixpkgs=flake:nixpkgs";
      bash-prompt-prefix = "(nix:$name)\\040";
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };

    services.openssh = {
      enable = true;
      # we want to force pin and touch of yubi key based auth
      # see https://developers.yubico.com/SSH/Securing_SSH_with_FIDO2.html
      extraConfig = "PubkeyAuthOptions = verify-required";
      settings = {
        # Only key based root login
        PermitRootLogin = lib.mkForce "prohibit-password";
        # Disable password authentication
        PasswordAuthentication = false;
      };
    };

    ## Allow wheel to
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

    # allow for persisten sessions and terminal window management
    programs.tmux.enable = true;

    # quality of life tools
    environment.systemPackages = [
      pkgs.age
      pkgs.htop
      pkgs.coreutils
      pkgs.git
      pkgs.curl
      pkgs.whois
      pkgs.dig
      pkgs.nmap
      pkgs.magic-wormhole
      pkgs.jq
      pkgs.nix-output-monitor
      pkgs.nvd
      pkgs.nh
      pkgs.zstd
      pkgs.unzip
      pkgs.vim
    ];
  };

}

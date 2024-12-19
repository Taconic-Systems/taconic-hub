{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (inputs.nixpkgs.lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.taconic.backup-server;
in
{

  options = {
    taconic.backup-server.enable = mkEnableOption "Enable Taconic bub backup services";
  };

  # import the server module from the bub flake
  imports = [
    (
      { ... }:
      {
        nixpkgs.overlays = [
          inputs.bub-nix.overlays.default
        ];
      }
    )
    "${inputs.bub-nix}/nixosModules/bub-server.nix"
  ];

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.bub
      pkgs.age
      pkgs.gnutar
      pkgs.zstd
    ];
    services.bub-server = {
      enable = true;
    };
    services.bub-server.users.bub = { };

    # to add ssh keys:
    # services.bub-server.users.bub.keys = ["sshpubkeys"];
  };

}

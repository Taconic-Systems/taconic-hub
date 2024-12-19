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
  cfg = config.taconic.backup-client;
in
{

  options = {
    taconic.backup-client.enable = mkEnableOption "Enable Taconic bub client";
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
  ];

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.bub
      pkgs.age
      pkgs.gnutar
      pkgs.openssh
      pkgs.zstd
    ];
  };

}

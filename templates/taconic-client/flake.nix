{
  description = "Taconic Systems Security Hub Configuration";
  inputs = {
    # We use the small stable nix channel by default
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05-small";
    # and have an unstable channel for bleeding edge packages
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    #hub.url = "github:Taconic-Systems/taconic-hub";
    hub = {
      url = "github:Taconic-Systems/taconic-hub";
      # url = "github:Taconic-Systems/taconic-hub/unstable";
      # for local development of the hub, point to a local clone of the repo
      # url = "path:/home/craig/projects/taconic-hub";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      #inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        #"aarch64-linux"
      ];
    in
    {

      # DevShell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            # Enable experimental features without having to specify the argument

            NIX_CONFIG = "experimental-features = nix-command flakes";
            nativeBuildInputs = with pkgs; [
              sops
              age
              gnupg
              nix-output-monitor
              nvd
            ];
          };
        }
      );

      #formatter = forAllSystems (system: self.packages."${system}".nixfmt);
      # Used with `nixos-rebuild --flake .#<hostname>`
      # https://daiderd.com/nix-darwin/manual/index.html

      # NixOs Hosts
      nixosConfigurations = {
        # the name here should match the hostname of the target system
        sechub = nixpkgs.lib.nixosSystem {
          specialArgs = {
            # we need to specify the system architecture here, as a
            # nixosConfiguration is specific to a machine, and if
            # deployed, also needs to include the generated
            # hardware-configuration.nix
            system = "x86_64-linux";
            inherit inputs outputs sops-nix;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/sechub ];
        };
      };
    };
}

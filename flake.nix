{
  description = "A Flake the Taconic Systems security hub";
  inputs = {
    # We track the stable release as the default source for packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # We pull a small set of packages from unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # This is for managing secrets with age
    # https://github.com/ryantm/agenix
    agenix.url = "github:ryantm/agenix";

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        # "i686-linux"
        "aarch64-linux"
        "x86_64-linux"
        #"aarch64-darwin"
        #"x86_64-darwin"
      ];
      inherit (inputs.nixpkgs.lib)
        attrValues
        makeOverridable
        optionalAttrs
        singleton
        ;
    in
    rec {

      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        import ./packages { inherit pkgs; }
      );

      # DevShell for bootstrapping      # Acessible through 'nix develop' or 'nix-shell' (legacy)
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
              agenix.packages."${system}".default
            ];
          };
        }
      );

      nixosModules = {
        taconic = import ./nixosModules/taconic.nix;
        default = self.nixosModules.taconic;
      };

      #formatter = forAllSystems (system: self.packages."${system}".nixfmt);
      # sudo nixos-container create gohello --flake .#container
      ## NixOs Hosts
      nixosConfigurations = {
        container = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/container.nix ];
        };
        vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/vm.nix ];
        };
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/installer.nix ];
        };

        silence = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/silence ];
        };
      };
    };
}

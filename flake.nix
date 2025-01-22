{
  description = "A Flake for the Taconic Systems security hub";
  inputs = {
    # We track the stable release as the default source for packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    # We pull a small set of packages from unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    bub-nix = {
      # we want to track the 24.11 release
      #url = "path:/home/craig/projects/bub";
      url = "github:Taconic-Systems/bub";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      templates = {
        taconic-client = {
          path = ./templates/taconic-client;
          description = "A template for Taconic Clients, be aware that this configures Taconic Systems access to the host.";
        };
      };
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
            ];
          };
        }
      );

      nixosModules = {
        taconic = ./nixosModules/taconic.nix;
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
          modules = [
            ./nixosConfigurations/container.nix

          ];
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
        # an experimental installer
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/installer.nix ];
        };

        example = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            system = "x86_64-linux";
            inherit inputs outputs;
            pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
          };
          modules = [ ./nixosConfigurations/example ];
        };
      };
    };
}

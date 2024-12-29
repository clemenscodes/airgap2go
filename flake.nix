{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    systems = {
      url = "github:nix-systems/default";
    };

    # For declarative block device provisioning
    disko = {
      url = "github:nix-community/disko";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    # For fetch-closure shrunk release packages with minimal eval time and dependency sizes
    # Currently x86_64-linux only
    capkgs = {
      url = "github:input-output-hk/capkgs";
    };

    # Required image signing tooling
    credential-manager = {
      url = "github:IntersectMBO/credential-manager";
    };

    # Even secure operations can be pretty
    catppuccin = {
      url = "github:catppuccin/nix";
    };

    # For better caps lock
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    # For various shell configs
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    # Just because
    nvim = {
      url = "github:cymenix/nvim";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };

    # New hot stuff
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    nixosModules = let
      system = "x86_64-linux";
      pkgs = import nixpkgs {inherit system;};
      inherit (pkgs) lib;
    in {
      default = import ./modules {inherit inputs pkgs nixpkgs system lib self;};
    };

    nixosConfigurations = let
      system = "x86_64-linux";
      pkgs = import nixpkgs {inherit system;};
      inherit (pkgs) lib;
    in {
      minimal = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs lib nixpkgs system;};
        modules = [
          self.nixosModules.default
          ({...}: {
            airgap = {
              enable = true;
              device = "/dev/sdc";
              keymap = "us";
              locale = "en_US.UTF-8";
              host = "airgap";
              user = "airgap";
              group = "airgap";
              initialPassword = "airgap";
              uid = 1234;
              home = {
                enable = false;
              };
              catppuccin = {
                enable = false;
              };
              ui = {
                enable = false;
                gnome = {
                  enable = false;
                };
              };
            };
          })
        ];
      };

      de_minimal_themed = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs lib nixpkgs system;};
        modules = [
          self.nixosModules.default
          ({...}: {
            airgap = {
              enable = true;
              device = "/dev/sdc";
              keymap = "de";
              locale = "de_DE.UTF-8";
              host = "airgap";
              user = "airgap";
              group = "airgap";
              initialPassword = "airgap";
              uid = 1234;
              home = {
                enable = true;
              };
              catppuccin = {
                enable = true;
              };
              ui = {
                enable = false;
                gnome = {
                  enable = false;
                };
              };
            };
          })
        ];
      };

      de_gnome_themed = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs lib nixpkgs system;};
        modules = [
          self.nixosModules.default
          ({...}: {
            airgap = {
              enable = true;
              device = "/dev/sdc";
              keymap = "de";
              locale = "de_DE.UTF-8";
              host = "airgap";
              user = "airgap";
              group = "airgap";
              initialPassword = "airgap";
              uid = 1234;
              home = {
                enable = true;
              };
              catppuccin = {
                enable = true;
              };
              ui = {
                enable = true;
                gnome = {
                  enable = true;
                };
              };
            };
          })
        ];
      };
    };

    packages = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      packages = import ./pkgs {inherit pkgs;};
    in {
      default = self.packages.${system}.airgap-install;
      inherit (packages) airgap-install airgap-update flake-closure copyro;
    });

    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        nativeBuildInputs = [pkgs.disko];
      };
    });

    formatter = forEachSystem (system: let pkgs = import nixpkgs {inherit system;}; in pkgs.alejandra);
  };

  nixConfig = {
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    extra-substituters = ["https://cache.iog.io"];
  };
}

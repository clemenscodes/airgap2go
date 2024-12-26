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
      default = import ./modules {inherit inputs pkgs nixpkgs system lib;};
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
              rootMountPoint = "/mnt/airgap";
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
            };
          })
        ];
      };

      de_full = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs lib nixpkgs system;};
        modules = [
          self.nixosModules.default
          ({...}: {
            airgap = {
              enable = true;
              rootMountPoint = "/mnt/airgap";
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
            };
          })
        ];
      };

      gnome_de_full = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs nixpkgs system;};
        modules = [
          self.nixosModules.default
          ({...}: {
            airgap = {
              enable = true;
              rootMountPoint = "/mnt/airgap";
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
    in {
      default = self.packages.${system}.airgap-install;
      airgap-install = pkgs.writeShellApplication {
        name = "airgap-install";
        runtimeInputs = with pkgs; [disko];
        text = ''
          usage() {
            echo "Usage: $0 [--dry-run] <device> [config]"
            echo "  --dry-run    Run in dry-run mode (does not require sudo)."
            echo "  <device>     Target device to install on (e.g., /dev/sdc)."
            echo "  <mountpoint> Where to mount the disk after formatting (e.g., /mnt/usb)."
            echo "  [config]     Nix flake output for disko-install (default: .#minimal)."
            exit 1
          }

          if [ "$#" -lt 1 ]; then
            usage
          fi

          DRY_RUN=false
          if [ "$1" == "--dry-run" ]; then
            DRY_RUN=true
            shift
          fi

          DEVICE=$1

          if [ -z "$DEVICE" ]; then
            echo "Error: <device> is required."
            usage
          fi

          MOUNTPOINT=$2

          if [ -z "$MOUNTPOINT" ]; then
            echo "Error: <mountpoint> is required."
            usage
          fi

          CONFIG=''${3:-.#minimal}

          if [ "$DRY_RUN" == true ]; then
            echo "Running in dry-run mode..."
            disko-install --dry-run --mode format -f "$CONFIG" --mount-point "$MOUNTPOINT" --disk main "$DEVICE"
          else
            echo "Running in actual mode (requires sudo)..."
            sudo disko-install --mode format -f "$CONFIG" --mount-point "$MOUNTPOINT" --disk main "$DEVICE"
          fi
        '';
      };
    });

    formatter = forEachSystem (system: let pkgs = import nixpkgs {inherit system;}; in pkgs.alejandra);
  };

  nixConfig = {
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    extra-substituters = ["https://cache.iog.io"];
  };
}

{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    airgap2go = {
      url = "github:clemenscodes/airgap2go";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    nixosConfigurations = {
      de_minimal_themed = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs nixpkgs system;};
        modules = [
          inputs.airgap2go.nixosModules.default
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
    };
  };
}

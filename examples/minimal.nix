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
      minimal = nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = {inherit self inputs pkgs system nixpkgs;};
        modules = [
          inputs.airgap2go.nixosModules.default
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
    };
  };
}

{
  inputs,
  pkgs,
  nixpkgs,
  system,
  lib,
  ...
}: {config, ...}: let
  cfg = config.airgap;
in {
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  options = {
    airgap = {
      home = {
        enable = lib.mkEnableOption "Enable a basic home config" // {default = false;};
      };
    };
  };
  config = lib.mkIf cfg.home.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit inputs pkgs nixpkgs system;};
      backupFileExtension = "home-manager-backup";
      users = {
        ${config.airgap.user} = {
          imports = [(import ./modules {inherit inputs pkgs nixpkgs system;})];
        };
      };
    };
  };
}

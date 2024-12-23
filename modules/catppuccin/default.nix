{
  inputs,
  lib,
  ...
}: {config, ...}: let
  cfg = config.airgap;
in {
  imports = [inputs.catppuccin.nixosModules.catppuccin];
  options = {
    airgap = {
      catppuccin = {
        enable = lib.mkEnableOption "Enable catppuccin theming" // {default = false;};
      };
    };
  };
  config = lib.mkIf cfg.catppuccin.enable {
    catppuccin = {
      inherit (cfg.catppuccin) enable;
      flavor = "macchiato";
      accent = "blue";
    };
    home-manager = lib.mkIf cfg.home.enable {
      users = {
        ${config.airgap.user} = {
          imports = [inputs.catppuccin.homeManagerModules.catppuccin];
          catppuccin = {
            inherit (cfg.catppuccin) enable;
            flavor = "macchiato";
            accent = "blue";
          };
        };
      };
    };
  };
}

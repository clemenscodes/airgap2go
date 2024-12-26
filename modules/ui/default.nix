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
  imports = [(import ./gnome {inherit inputs pkgs nixpkgs system lib;})];
  options = {
    airgap = {
      ui = {
        enable = lib.mkEnableOption "Enable a UI" // {default = false;};
      };
    };
  };
  config = lib.mkIf config.airgap.ui.enable {
    home-manager = lib.mkIf config.airgap.home.enable {
      users = {
        ${cfg.user} = {
          programs = {
            kitty = {
              inherit (cfg.ui) enable;
              font = {
                name = "Iosevka Nerd Font";
                package = pkgs.nerd-fonts.iosevka;
                size = 16;
              };
            };
          };
        };
      };
    };
  };
}

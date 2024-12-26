{
  pkgs,
  lib,
  ...
}: {config, ...}: let
  cfg = config.airgap.ui;
in {
  options = {
    airgap = {
      ui = {
        gnome = {
          enable = lib.mkEnableOption "Enable GNOME" // {default = false;};
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.gnome.enable) {
    services = {
      xserver = {
        inherit (cfg.gnome) enable;
        desktopManager = {
          gnome = {
            inherit (cfg.gnome) enable;
          };
        };
        displayManager = {
          gdm = {
            inherit (cfg.gnome) enable;
          };
        };
      };

      udev = {
        packages = [pkgs.gnome-settings-daemon];
      };
    };

    programs = {
      dconf = {
        inherit (cfg.gnome) enable;
      };
    };

    fonts = {
      packages = with pkgs; [
        nerd-fonts.iosevka
      ];
    };

    environment = {
      systemPackages = [
        pkgs.adwaita-icon-theme
        pkgs.gnomeExtensions.appindicator
      ];
      gnome = {
        excludePackages = with pkgs; [
          orca
          evince
          geary
          gnome-bluetooth
          gnome-software
          yelp
          totem
          snapshot
          simple-scan
          gnome-connections
          gnome-weather
          gnome-music
          gnome-photos
          gnome-maps
          gnome-logs
          gnome-font-viewer
          gnome-contacts
          gnome-console
          gnome-calendar
          gnome-calculator
          gnome-text-editor
          epiphany
          baobab
          gnome-user-docs
          gnome-tour
          tali
          atomix
          cheese
          iagno
          gnome-characters
        ];
      };
    };
  };
}
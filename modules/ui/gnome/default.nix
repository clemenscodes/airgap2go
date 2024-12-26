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

      displayManager = {
        autoLogin = {
          inherit (config.airgap) user;
        };
      };
      udev = {
        packages = [pkgs.gnome-settings-daemon];
      };
    };

    users = {
      allowNoPasswordLogin = true;
    };

    systemd = {
      services = {
        "getty@tty1" = {
          enable = false;
        };
        "autovt@tty1" = {
          enable = false;
        };
      };
      user = {
        services = {
          dconf-defaults = {
            script = let
              dconfDefaults = pkgs.writeText "dconf.defaults" ''
                [org/gnome/desktop/background]
                color-shading-type='solid'
                picture-options='zoom'
                picture-uri='${../../../assets/cardano.png}'
                primary-color='#000000000000'
                secondary-color='#000000000000'

                [org/gnome/desktop/lockdown]
                disable-lock-screen=true
                disable-log-out=true
                disable-user-switching=true

                [org/gnome/desktop/notifications]
                show-in-lock-screen=false

                [org/gnome/desktop/screensaver]
                color-shading-type='solid'
                lock-delay=uint32 0
                lock-enabled=false
                picture-options='zoom'
                picture-uri='${../../../assets/cardano.png}'
                primary-color='#000000000000'
                secondary-color='#000000000000'

                [org/gnome/settings-daemon/plugins/media-keys]
                custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

                [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
                binding='<Primary><Alt>t'
                command='kgx'
                name='console'

                [org/gnome/settings-daemon/plugins/power]
                idle-dim=false
                power-button-action='interactive'
                sleep-inactive-ac-type='nothing'
              '';
            in ''
              ${pkgs.dconf}/bin/dconf load / < ${dconfDefaults}
            '';
            wantedBy = ["graphical-session.target"];
            partOf = ["graphical-session.target"];
          };
        };
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

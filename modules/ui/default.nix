{
  inputs,
  pkgs,
  nixpkgs,
  system,
  lib,
  ...
}: {config, ...}: let
  cfg = config.airgap;
  iconTheme = pkgs.catppuccin-papirus-folders.override {
    flavor = "macchiato";
    accent = "blue";
  };
  theme = {
    name = "Colloid-Dark-Catppuccin";
    package = pkgs.colloid-gtk-theme.override {tweaks = ["catppuccin"];};
  };
  themePath = "${theme.package}/share/themes/${theme.name}";
  kvantum = pkgs.catppuccin-kvantum.override {
    accent = "blue";
    variant = "macchiato";
  };
  font = pkgs.nerd-fonts.iosevka;
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
    qt = {
      enable = true;
    };
    gtk = {
      iconCache = {
        enable = true;
      };
    };
    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = ["Iosevka Nerd Font Mono"];
          sansSerif = ["Iosevka Nerd Font"];
          serif = ["Iosevka Nerd Font"];
        };
      };
      fontDir = {
        enable = true;
      };
      packages = [font];
    };
    home-manager = lib.mkIf config.airgap.home.enable {
      users = {
        ${cfg.user} = {
          home = {
            pointerCursor = {
              name = "catppuccin-macchiato-blue-cursors";
              package = pkgs.catppuccin-cursors.macchiatoBlue;
              size = 12;
            };
            packages = with pkgs; [
              inputs.ghostty.packages.${system}.default
              libsForQt5.qtstyleplugin-kvantum
              libsForQt5.qt5ct
              libsForQt5.qt5.qtwayland
              libsForQt5.breeze-icons
              hicolor-icon-theme
              catppuccin-qt5ct
              qt6.qtwayland
              kvantum
            ];
            sessionVariables = {
              QT_QPA_PLATFORM = "wayland;xcb";
              QT_QPA_PLATFORMTHEME = "kvantum";
              QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              QT_AUTO_SCREEN_SCALE_FACTOR = "1";
              SDL_VIDEODRIVER = "wayland";
              GDK_BACKEND = "wayland,x11,*";
              GTK_THEME = theme.name;
            };
            file = {
              ".icons/Papirus-Dark" = {
                source = "${iconTheme}/share/icons/Papirus-Dark";
              };
              ".local/share/.icons/Papirus-Dark" = {
                source = "${iconTheme}/share/icons/Papirus-Dark";
              };
            };
          };
          xdg = {
            enable = true;
            userDirs = {
              createDirectories = true;
            };
            mimeApps = {
              enable = true;
            };
            portal = {
              enable = true;
              xdgOpenUsePortal = true;
              extraPortals = [pkgs.xdg-desktop-portal-gtk];
              config = {
                common = {
                  default = "*";
                };
              };
            };
            configFile = {
              "gtk-2.0/assets".source = "${themePath}/gtk-2.0/assets";
              "gtk-2.0/apps.rc".source = "${themePath}/gtk-2.0/apps.rc";
              "gtk-2.0/gtkrc".source = "${themePath}/gtk-2.0/gtkrc";
              "gtk-2.0/hacks.rc".source = "${themePath}/gtk-2.0/hacks.rc";
              "gtk-2.0/main.rc".source = "${themePath}/gtk-2.0/main.rc";
              "gtk-3.0/assets".source = "${themePath}/gtk-3.0/assets";
              "gtk-3.0/gtk.css".source = "${themePath}/gtk-3.0/gtk.css";
              "gtk-3.0/gtk-dark.css".source = "${themePath}/gtk-3.0/gtk-dark.css";
              "gtk-4.0/assets".source = "${themePath}/gtk-4.0/assets";
              "gtk-4.0/gtk.css".source = "${themePath}/gtk-4.0/gtk.css";
              "gtk-4.0/gtk-dark.css".source = "${themePath}/gtk-4.0/gtk-dark.css";
            };
          };
          gtk = {
            enable = true;
            inherit theme;
            cursorTheme = lib.mkForce {
              package = pkgs.catppuccin-cursors.macchiatoBlue;
              name = "catppuccin-macchiato-blue-cursors";
            };
            iconTheme = {
              package = iconTheme;
              name = "Papirus-Dark";
            };
            font = {
              package = font;
              name = "Iosevka Nerd Font";
              size = 12;
            };
            gtk2 = {
              configLocation = "${config.home-manager.users.${config.airgap.user}.xdg.configHome}/gtk-2.0/settings.ini";
              extraConfig = ''
                gtk-application-prefer-dark-theme=1
              '';
            };
            gtk3 = {
              extraConfig = {
                gtk-application-prefer-dark-theme = 1;
              };
            };
            gtk4 = {
              extraConfig = {
                gtk-application-prefer-dark-theme = 1;
              };
            };
          };
          qt = {
            enable = true;
            platformTheme = {
              name = "kvantum";
            };
            style = {
              name = "kvantum";
              package = kvantum;
            };
          };
        };
      };
    };
  };
}

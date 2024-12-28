{
  inputs,
  nixpkgs,
  pkgs,
  system,
  self,
  ...
}: {config, ...}: let
  cfg = config.airgap;
  inherit (pkgs) lib;
in {
  imports = [
    inputs.xremap-flake.nixosModules.default
    (import ./airgap {inherit inputs nixpkgs pkgs system lib self;})
    (import ./catppuccin {inherit inputs nixpkgs pkgs system lib;})
    (import ./home {inherit inputs nixpkgs pkgs system lib;})
    (import ./ui {inherit inputs nixpkgs pkgs system lib;})
  ];

  options = {
    airgap = {
      enable = lib.mkEnableOption "Enable airgap" // {default = false;};
      host = lib.mkOption {
        type = lib.types.str;
        description = "The hostname of the installed device";
        example = "airgap";
        default = "airgap";
      };
      user = lib.mkOption {
        type = lib.types.str;
        description = "The name of the airgap user";
        example = "airgap";
        default = "airgap";
      };
      group = lib.mkOption {
        type = lib.types.str;
        description = "The group of the airgap user";
        example = "airgap";
        default = "airgap";
      };
      initialPassword = lib.mkOption {
        type = lib.types.str;
        description = "The inital password of the airgap user, that should be changed";
        example = "CHANGE_ME_BECAUSE_I_AM_INSECURE";
        default = "airgap";
      };
      uid = lib.mkOption {
        type = lib.types.int;
        description = "The id of the airgap user";
        example = 1000;
        default = 1234;
      };
      device = lib.mkOption {
        type = lib.types.str;
        description = "The device to install the filesystem on using disko";
        example = "/dev/sdc";
      };
      rootMountPoint = lib.mkOption {
        type = lib.types.str;
        description = "Where ${cfg.device} will be mounted after formatting with disko";
        default = "/mnt/disko-install-root";
        example = "/mnt/usb";
      };
      locale = lib.mkOption {
        type = lib.types.str;
        description = "The locale to use";
        default = "en_US.UTF-8";
        example = "de_DE.UTF-8";
      };
      keymap = lib.mkOption {
        type = lib.types.str;
        description = "The keyboard leyout to use";
        default = "us";
        example = "de";
      };
    };
  };
}

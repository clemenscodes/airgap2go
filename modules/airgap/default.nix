{
  inputs,
  pkgs,
  lib,
  system,
  ...
}: {config, ...}: let
  cfg = config.airgap;
  capkgs = inputs.capkgs.packages.${system};
  bech32 = capkgs.bech32-input-output-hk-cardano-node-10-1-3-36871ba;
  cardano-address = capkgs.cardano-address-cardano-foundation-cardano-wallet-v2024-11-18-9eb5f59;
  cardano-cli = capkgs.cardano-cli-input-output-hk-cardano-node-10-1-3-36871ba;
  inherit (inputs.credential-manager.packages.${system}) orchestrator-cli cc-sign;
  inherit (inputs.disko.packages.${system}) disko;
in {
  imports = [
    (import ./boot {inherit inputs pkgs lib system;})
    (import ./disk {inherit inputs pkgs lib system;})
  ];

  system = {
    stateVersion = lib.versions.majorMinor lib.version;
  };

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      accept-flake-config = true
    '';

    nixPath = ["nixpkgs=${pkgs.path}"];
    settings = {
      substituters = lib.mkForce [];
      trusted-users = [cfg.user];
    };
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault system;
  };

  hardware = {
    bluetooth = {
      enable = lib.mkForce false;
    };
  };

  networking = {
    hostName = cfg.host;
    enableIPv6 = lib.mkForce false;
    interfaces = lib.mkForce {};
    useDHCP = lib.mkForce false;
    networkmanager = {
      enable = lib.mkForce false;
    };
    wireless = {
      enable = lib.mkForce false;
    };
  };

  users = {
    defaultUserShell = pkgs.zsh;
    mutableUsers = true;

    users = {
      ${cfg.user} = {
        inherit (cfg) group uid initialPassword;
        createHome = true;
        extraGroups = ["wheel"];
        home = "/home/${cfg.user}";
        isNormalUser = true;
      };
    };

    groups = {
      ${cfg.user} = {};
    };
  };

  console = {
    earlySetup = true;
    keyMap = cfg.keymap;
  };

  i18n = {
    defaultLocale = cfg.locale;
    supportedLocales = ["all"];
  };

  documentation = {
    enable = false;
  };

  environment = {
    shells = with pkgs; [zsh];
    systemPackages =
      (with pkgs; [
        cfssl
        cryptsetup
        gnupg
        jq
        lvm2
        openssl
        pwgen
        usbutils
        util-linux
        ncdu
        btop
      ])
      ++ [
        disko
        bech32
        cardano-address
        cardano-cli
        orchestrator-cli
        cc-sign
      ];
  };

  programs = {
    zsh = {
      enable = true;
    };

    gnupg = {
      agent = {
        enable = true;
      };
    };
  };

  services = {
    xserver = {
      xkb = {
        layout = cfg.keymap;
      };
    };

    udev = {
      extraRules = ''
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="2b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="3b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="4b7c", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1807", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="1808", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0000", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0004", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2c97"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", ATTRS{idVendor}=="2581"
        ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"
      '';
    };

    xremap = {
      enable = true;
      watch = true;
      userName = cfg.user;
      yamlConfig = ''
        modmap:
          - name: "Better CapsLock"
            remap:
              CapsLock:
                held: SUPER_L
                alone: ESC
                alone_timeout_millis: 500
      '';
    };
  };
}

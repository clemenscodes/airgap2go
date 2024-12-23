{pkgs, ...}: {config, ...}: let
  cfg = config.airgap;
in {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = ["kvm-intel"];

    supportedFilesystems = ["ext4" "vfat" "btrfs" "ntfs"];

    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        enableCryptodisk = true;
        copyKernels = true;
        mirroredBoots = [
          {
            path = "/boot";
            devices = [cfg.device];
          }
        ];
      };
    };

    initrd = {
      availableKernelModules = [
        "ohci_pci"
        "ohci_hcd"
        "ehci_pci"
        "ehci_hcd"
        "xhci_pci"
        "xhci_hcd"
        "uas"
        "usb-storage"
        "usbhid"
        "ahci"
      ];
    };

    blacklistedKernelModules = [
      "e1000e"
      "r8169"
      "iwlwifi"
      "ath9k"
      "brcmfmac"
      "rtl8188ee"
      "bluetooth"
    ];
  };
}

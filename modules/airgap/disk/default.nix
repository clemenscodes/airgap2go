{inputs, ...}: {config, ...}: let
  cfg = config.airgap;
in {
  imports = [inputs.disko.nixosModules.disko];
  disko = {
    inherit (cfg) rootMountPoint;
    devices = {
      disk = {
        main = {
          inherit (cfg) device;
          type = "disk";
          content = {
            type = "gpt";
            efiGptPartitionFirst = false;
            partitions = {
              MBR = {
                priority = 1;
                type = "EF02";
                size = "1M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = null;
                };
                hybrid = {
                  mbrPartitionType = "0x0c";
                  mbrBootableFlag = false;
                };
              };
              ESP = {
                type = "EF00";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              public = {
                size = "8G";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/public";
                  mountOptions = ["umask=0000"];
                };
              };
              luks = {
                size = "100%";
                content = {
                  type = "luks";
                  name = "encrypted";
                  askPassword = true;
                  settings = {
                    allowDiscards = true;
                  };
                  extraFormatArgs = ["--label encrypted"];
                  postMountHook = "dmsetup ls --target crypt --exec 'cryptsetup close' 2> /dev/null";
                  content = {
                    type = "lvm_pv";
                    vg = "pool";
                  };
                };
              };
            };
          };
        };
      };
      lvm_vg = {
        pool = {
          type = "lvm_vg";
          lvs = {
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

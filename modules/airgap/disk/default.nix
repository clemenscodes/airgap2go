{
  inputs,
  lib,
  ...
}: {config, ...}: let
  cfg = config.airgap;
in {
  imports = [inputs.disko.nixosModules.disko];
  disko = {
    rootMountPoint = lib.mkDefault cfg.rootMountPoint;
    devices = {
      disk = {
        main = {
          device = lib.mkDefault cfg.device;
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
                priority = 2;
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
                priority = 3;
                size = "256M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/public";
                  mountOptions = ["umask=0000"];
                };
              };
              private = {
                priority = 4;
                size = "256M";
                content = {
                  type = "luks";
                  name = "private";
                  askPassword = true;
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/private";
                  };
                };
              };
              root = {
                priority = 5;
                size = "100%";
                content = {
                  type = "luks";
                  name = "root";
                  askPassword = true;
                  settings = {
                    allowDiscards = true;
                  };
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
    };
  };
}

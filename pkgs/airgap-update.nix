{pkgs, ...}: let
  name = "airgap-update";
in
  pkgs.writeShellScriptBin name ''
    usage() {
      echo "Usage: ${name} [device] [config]"
      echo "  [device] The device to write the update to (e.g.: /dev/sdc)"
      echo "  [config] Nix flake output to update (e.g.: github:clemenscodes/airgap2go#minimal)"
      exit 1
    }

    error() {
      echo "Error: Invalid config or $1 not found."
      exit 1
    }

    if [ "$#" -lt 1 ]; then
      usage
    fi

    DEVICE=$1

    if [ -z "$DEVICE" ]; then
      echo "Error: <device> is required."
      usage
    fi

    CONFIG=''${2:-github:clemenscodes/airgap2go#minimal}
    NIXOS_CONFIG=$(echo "$CONFIG" | awk -v insert="nixosConfigurations." -F'#' '{print $1 "#" insert $2}')

    nix build "$NIXOS_CONFIG".config.system.build.toplevel

    echo "Writing update to $DEVICE"
    storePath=$(nix-store -q --deriver ./result)
    nix-store --export $(nix-store -qR $storePath) | sudo dd of="$DEVICE" status=progress
    echo "Finished writing update to $DEVICE"
  ''

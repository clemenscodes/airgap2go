{pkgs, ...}:
pkgs.writeShellApplication {
  name = "airgap-install";
  runtimeInputs = with pkgs; [disko];
  text = ''
    usage() {
      echo "Usage: $0 [--dry-run] [--update] [config]"
      echo "  --dry-run    Run in dry-run mode"
      echo "  --update     Update only"
      echo "  [config]     Nix flake output for disko-install (default: github:clemenscodes/airgap2go#minimal)"
      exit 1
    }

    error() {
      echo "Error: Invalid config or $1 not found."
      exit 1
    }

    resolve_config_value() {
      local config
      local path
      local full_uri
      local value

      config=$1
      path=$2
      full_uri=$(echo "$config" | awk -v insert="nixosConfigurations." -F'#' '{print $1 "#" insert $2}')
      value=$(nix eval "$full_uri.$path" 2>/dev/null || error "$path")
      value=$(echo "$value" | tr -d '"')

      echo "$value"
    }

    if [ "$#" -lt 1 ]; then
      usage
    fi

    DRY_RUN=false
    if [ "$#" -ge 1 ] && [ "$1" == "--dry-run" ]; then
      DRY_RUN=true
      shift
    fi

    MODE="format"
    if [ "$#" -ge 1 ] && [ "$1" == "--update" ]; then
      MODE="mount"
      shift
    fi

    CONFIG=''${1:-github:clemenscodes/airgap2go#minimal}
    DEVICE=$(resolve_config_value "$CONFIG" "config.airgap.device")
    MOUNTPOINT=$(resolve_config_value "$CONFIG" "config.airgap.rootMountPoint")

    if [ "$DRY_RUN" == true ]; then
      echo "Running in dry-run mode..."
      echo "Unmounting all partitions of $DEVICE"
      echo "Wiping all data of $DEVICE..."
      echo "Would run: sudo shred -v -n 0 -z $DEVICE"
      echo "Fully formatted $DEVICE"
      disko-install --dry-run --mode "$MODE" -f "$CONFIG" --mount-point "$MOUNTPOINT" --disk main "$DEVICE"
    else
      echo "Running in actual mode (requires sudo)..."
      echo "Unmounting all partitions of $DEVICE"
      lsblk -ln -o PATH,MOUNTPOINT | grep "$DEVICE" | awk '$2 != "" {print $1}' | xargs -r umount
      echo "Unmounted all partitions of $DEVICE"
      echo "Wiping all data of $DEVICE..."
      sudo shred -v -n 0 -z "$DEVICE"
      echo "Fully formatted $DEVICE"
      sudo disko-install --mode "$MODE" -f "$CONFIG" --mount-point "$MOUNTPOINT" --disk main "$DEVICE"
    fi
  '';
}

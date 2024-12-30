{pkgs, ...}:
pkgs.writeShellApplication rec {
  name = "airgap-update";
  runtimeInputs = with pkgs; [disko];
  text = ''
    usage() {
      echo "Usage: ${name} [config]"
      echo "  [config] Nix flake output to update (e.g.: github:clemenscodes/airgap2go#minimal)"
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


    CONFIG=''${1:-github:clemenscodes/airgap2go#minimal}
    NIXOS_CONFIG=$(echo "$CONFIG" | awk -v insert="nixosConfigurations." -F'#' '{print $1 "#" insert $2}')
    UPDATE_PATH="$(pwd)/update"

    mkdir -p "$UPDATE_PATH"/cache

    nix build "$NIXOS_CONFIG".config.system.build.toplevel
    nix-store -qR --include-outputs "$(nix-store -q --deriver ./result )" | nix copy --to file://"$UPDATE_PATH"
    cp -r ~/.cache/nix/eval* "$UPDATE_PATH"/cache
  '';
}

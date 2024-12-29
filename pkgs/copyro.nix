{pkgs, ...}:
pkgs.writeShellApplication {
  name = "copyro";
  runtimeInputs = with pkgs; [disko];
  text = ''
    SOURCE_DIR=$1
    DEST_DIR=$2

    if [ ! -d "$DEST_DIR" ]; then
      echo "Destination does not exist. Starting copy process."

      copy_directory() {
        local src="$1"
        local dest="$2"

        mkdir -p "$dest"

        for item in "$src"/*; do
          [ -e "$item" ] || continue
          local dest_item="$dest/$(basename "$item")"
          if [ -d "$item" ]; then
            copy_directory "$item" "$dest_item"
          elif [ -f "$item" ]; then
            cp "$item" "$dest_item"
          fi
        done
      }

      copy_directory "$SOURCE_DIR" "$DEST_DIR"
      echo "Copy process completed successfully."
    else
      echo "Destination already exists. No action taken."
    fi
  '';
}

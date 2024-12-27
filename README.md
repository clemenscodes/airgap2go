# airgap2go

**airgap2go** is a tool for creating a secure, encrypted live USB that boots into an  
airgapped NixOS environment preloaded with essential cryptographic tools. This setup  
is designed to help you manage sensitive cryptographic operations in an isolated,  
offline environment, reducing the risk of key exposure or unauthorized access.

Whether you're a **Cardano Stake Pool Operator (SPO)** or simply someone who values  
a high level of security for managing private keys, **airgap2go** provides a robust  
solution. It ensures that your private keys are stored securely on an encrypted  
partition and enables you to execute cryptographic tasks with confidence. For  
example, you can build blockchain transactions or sign messages using your private  
keys without exposing them to an online system.

The generated USB supports both BIOS and UEFI systems, leveraging a hybrid MBR  
partition scheme implemented using `disko`. After installation, you’ll boot into  
the secure environment by decrypting the root partition. Once booted and logged in,  
you can carry out cryptographic operations and transfer the results (e.g., signed  
transactions or public keys) to the `/public` partition, making them accessible for  
use on your connected systems.

## Key Features

- **Secure Airgapped Environment**: Operate in a fully offline environment, ensuring  
  maximum security for sensitive cryptographic tasks.
- **Preinstalled Cryptographic Tools**: Includes tools commonly used for signing,  
  encrypting, and decrypting data.
- **Hybrid Boot Support**: Compatible with both BIOS and UEFI systems using a hybrid  
  MBR partition scheme.
- **Encrypted Storage**: The root partition is fully encrypted to protect your  
  private keys and sensitive data.

## Requirements

- Nix
- USB drive (16GB or larger)

## Setting Up the Air-Gapped Device Configuration

1. **Identify the Device:**
   Note the name of the device you want to use, such as `/dev/sdc`. Ensure this device is correct and does not contain any data you wish to keep, as it will be wiped during the installation process.

2. **Edit the Configuration:**
   Open your `flake.nix` file and modify the configuration to include the desired device. Below is an example configuration:

```nix
   default = nixpkgs.lib.nixosSystem rec {
     inherit system;
     specialArgs = { inherit self inputs pkgs lib nixpkgs system; };
     modules = [
       self.nixosModules.default
       ({...}: {
         airgap = {
           enable = true;
           device = "/dev/sdc"; # Set your device name here
           keymap = "de"; # Keyboard layout
           locale = "de_DE.UTF-8"; # System locale
           host = "airgap"; # Hostname
           user = "airgap"; # Default user
           group = "airgap"; # User's group
           initialPassword = "airgap"; # Temporary default password
           uid = 1234; # User ID
           home = {
             enable = true; # Enable home directory setup
           };
           catppuccin = {
             enable = true; # Enable optional Catppuccin theming
           };
         };
       })
     ];
   };
```

### Step 1: Identify the USB Device

First, identify the device name of your USB drive:

```sh
lsblk
```

Note the device name, .e.g. `/dev/sdc`.

Then set the device in the configuration in [flake.nix](./flake.nix)

```nix
default = nixpkgs.lib.nixosSystem rec {
  inherit system;
  specialArgs = {inherit self inputs pkgs lib nixpkgs system;};
  modules = [
    self.nixosModules.default
    ({...}: {
      airgap = {
        enable = true;
        device = "/dev/sdc"; # Set the device here
        keymap = "us";
        locale = "en_US.UTF-8";
        host = "airgap";
        user = "airgap";
        group = "airgap";
        initialPassword = "airgap";
        uid = 1234;
        home = {
          enable = false;
        };
        catppuccin = {
          enable = false;
        };
      };
    })
  ];
};
```

Adjust the options according to your preferences.

> [!IMPORTANT]
> Change the `initialPassword` field to a secure default password or ensure you update it immediately after installation.

## Testing the Configuration

Test the configuration by using `--dry-run`, passing flake output for the system.

> [!IMPORTANT]
> Make sure that `device` and `rootMountPoint` match the definition in the NixOS module.

```sh
export FLAKE_CONFIG=".#minimal"
nix run .#airgap-install -- --dry-run "$FLAKE_CONFIG"
```

When happy with the results, proceed to installation

> [!CAUTION]
> Running the installation will erase all data on the target USB device.
> Ensure you have backed up any important data
> and double-check that the correct device is specified in the configuration (`/dev/sdc` in this example).

```sh
export FLAKE_CONFIG=".#default"
nix run .#airgap-install -- "$FLAKE_CONFIG"
```

During the process, you will be prompted to set a password for disk encryption.
The installation process can take up to an hour or longer depending on your system and device.

## Examples

See [here](./examples/minimal.nix) for a example and [here](./examples/de_full.nix) for an example that uses a more optimized configuration.

You could also install the airgap2go device by pointing to your own flake by referencing the installer directly

```sh
export FLAKE_CONFIG="github:clemenscodes/airgap2go#gnome_de_full" # Replace with a reference to your own config
nix run github:clemenscodes/airgap2go#airgap-install -- "$FLAKE_CONFIG"
```

## Acknowledgements

This was inspired by [Frankenwallet](https://github.com/rphair/frankenwallet) and [cardano-airgap](https://github.com/IntersectMBO/cardano-airgap).

To read more, you can also check out the official Cardano [documentation](https://developers.cardano.org/docs/get-started/air-gap/).

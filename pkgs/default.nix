{pkgs, ...}: {
  airgap-install = import ./airgap-install.nix {inherit pkgs;};
  airgap-update = import ./airgap-update.nix {inherit pkgs;};
  flake-closure = import ./flake-closure.nix {inherit pkgs;};
}

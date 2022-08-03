{
  inputs = { utils.url = "github:numtide/flake-utils"; };
  outputs = inputs@{ self, nixpkgs, utils }:
    let
      specialArgs = { inherit inputs; };
      buildConfig = system: modules: { inherit modules system specialArgs; };
      buildSystem = system: modules:
        nixpkgs.lib.nixosSystem (buildConfig system modules);

    in utils.lib.eachDefaultSystem (system:

      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell { buildInputs = with pkgs; [ nixfmt ]; };
        packages = rec {
          sd-image =
            self.nixosConfigurations.usbproxy.config.system.build.sdImage;
          default = sd-image;
        };
      }) // {

        nixosConfigurations = {
          usbproxy = buildSystem "aarch64-linux" [
            ({ config, pkgs, ... }: {
              system.stateVersion = "22.11";
              networking.hostName = "usbproxy";

              imports = [
                "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel.nix"
                ./hw.nix
                ./usbip.nix
              ];
              nix = {
                nixPath = [ "nixpkgs=${nixpkgs}" ];
                gc.automatic = true;
                settings = {
                  experimental-features = [ "nix-command" "flakes" ];
                };
              };

              networking.firewall.enable = false;
              environment.defaultPackages = with pkgs; [
                vim
                usbutils
                strace
                mtr
                config.boot.kernelPackages.usbip
              ];
              services.openssh.enable = true;

              users.extraUsers.root.openssh.authorizedKeys.keys = [
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9sqP5CegzzhdZpBkpfM6zlQFDN70krRFhLrXXvYsUSKL+pozGlcYjsX0xCbvFgGm4aY3gnVZo++nv3hLGM7YWIUpUHvGVLHL2bw4UODMPHgVFppv/H6adCaBJf3jbt1k2NtIq79S0nnpgUnjVIwu9XhZkhhBp5vS37LVGM7BOtx5Q5wIh5mYVMPsrNPKyu1pnKk9uyOYBycUqhtA18X21XCFeeWQUXRWRvN+ns8Wlteu4uuHRyUAlENO/JRruJVzeQPEmBrqLx5OvP8GGlNWIVnyke/UI96W3o/GsDB5BiKn6CVXc5PbAxlgj6nMPr0t0Uu8P5ki74Z18c3WB0snt"
              ];

            })
          ];
        };

      };

}

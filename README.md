# usbproxy

Small RPi4 NixOS image/config flake I made for @potan.

It’s as barebones as it gets, so feel free to use it as a base for your configs.
There’s a simple usbip module in [usbip.nix](./usbip.nix), which is not in nixpkgs as of yet.

It also tries and fails to enable host mode on USB-C port, see [hw.nix](./hw.nix).

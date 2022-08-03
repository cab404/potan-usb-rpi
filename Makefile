##
# Project Title
#
# @file
# @version 0.1

switch:
	nixos-rebuild switch --flake .#usbproxy --target-host root@usbproxy

build-sd-image:
	nix build .#sd-image -Lv

# end

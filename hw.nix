{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    (inputs.nixpkgs
      + "/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel.nix")
  ];

  sdImage = {
    populateFirmwareCommands = lib.mkForce (let
      configTxt = pkgs.writeText "config.txt" ''
        [pi4]
        kernel=u-boot-rpi4.bin
        enable_gic=1
        armstub=armstub8-gic.bin

        # Otherwise the resolution will be weird in most cases, compared to
        # what the pi3 firmware does by default.
        disable_overscan=1

        # Supported in newer board revisions
        arm_boost=1
        dtoverlay=dwc2
        dr_mode=host

        [all]
        # Boot in 64-bit mode.
        arm_64bit=1

        # U-Boot needs this to work, regardless of whether UART is actually used or not.
        # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
        # a requirement in the future.
        enable_uart=1

        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1
        disable_splash=1

      '';
    in ''
      (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

      # Add the config
      cp ${configTxt} firmware/config.txt

      # Add pi4 specific files
      cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
      cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4s.dtb firmware/
    '');
  };
}

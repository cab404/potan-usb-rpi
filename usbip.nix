{ config, lib, pkgs, ... }:
let usbip = config.boot.kernelPackages.usbip;
in {
  boot = { kernelModules = [ "usbip-host" ]; };

  systemd.services."usbip-up@" = {
    path = with pkgs; [ usbip ];
    script = ''
      usbipd
    '';

    postStart = ''
      usbip bind -b 1-1.1.1
    '';

    postStop = ''
      usbip unbind -b 1-1.1.1
    '';

    scriptArgs = "%i";
    partOf = [ "multiuser.target" ];
  };

}

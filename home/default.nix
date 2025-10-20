{ config, pkgs, ... }:
{
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "LDprg";
      userEmail = "lukas_4dr@gmx.at";
    };
    kitty.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      "$mod" = "SUPER";
      monitor = [
        "Virtual-1, 1920x1200@60, auto, auto"
        ",prefered, auto, 1"
      ];
      input = {
        kb_layout = "de";
      };
      bind = [
        "$mod, Q, exec, kitty"
        "$mod, M, exit"
        "$mod, F, exec, floorp"
      ];
    };
    package = null;
    portalPackage = null;
  };

  systemd.user.startServices = "sd-switch";

  # home.sessionVariables.NIXOS_OZONE_WL = "1";
  home.stateVersion = "25.05";
}

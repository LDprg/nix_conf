{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "LDprg";
      userEmail = "lukas_4dr@gmx.at";
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
    kitty.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      plugins = [
        {
          name = "fzf.fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
      ];
      shellAbbrs = {
        v = "vim";
      };
    };
    fzf.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  home.pointerCursor = {
    package = pkgs.rose-pine-hyprcursor;
    name = "rose-pine-hyprcursor";
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };

  home.packages = with pkgs; [
    cliphist
    wl-clipboard
  ];

  programs.hyprlock.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      exec-once = [
        "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --watch ${lib.getExe pkgs.cliphist} store"
      ];
      "$mod" = "SUPER";
      monitor = [
        "Virtual-1, 2560x1440@144, auto, 1"
        ",prefered, auto, 1"
      ];
      input = {
        kb_layout = "de";
      };
      bind = [
        "$mod, Q, exec, kitty"
        "$mod, M, exit"
        "$mod, F, exec, floorp"
        "$mod, L, exec, hyprlock"
      ];
    };
    package = null;
    portalPackage = null;
  };

  home.file."${config.xdg.configHome}/uwsm/env".text = ''
    # perfer wayland for qt apps
    export QT_QPA_PLATFORM=wayland;xcb

    # perfer wayland for gtk apps
    export GDK_BACKEND=wayland,x11,*

    # run sdl apps on wayland
    export SDL_VIDEODRIVER=wayland

    # autoscale qt apps based on monitor
    export QT_AUTO_SCREEN_SCALE_FACTOR=1

    # force electron apps to use wayland
    export NIXOS_OZONE_WL=1
    export ELECTRON_OZONE_PLATFORM_HINT=auto
  '';

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.05";
}

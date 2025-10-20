{ user, config, ... }: {
  programs = {
    home-manager.enable = true;
    git.enable = true;

    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
  };

  home.stateVersion = "25.05";
}

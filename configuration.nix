{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk_config.nix
    ./swap.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  #  Reset root subvolume on boot
  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
      mount /dev/disk/by-partlabel/disk-main-root /btrfs_tmp # CONFIRM THIS IS CORRECT FROM findmnt
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
  '';

  # Use /persist as the persistence root, matching Disko's mountpoint
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc" # System configuration (Keep this here for persistence via bind-mount)
      "/var/spool" # Mail queues, cron jobs
      "/srv" # Web server data, etc.
      "/root"
    ];
    files = [
    ];
  };

  custom = {
    zram.enable = true;
  };
  boot.loader.systemd-boot.enable = true;

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    helix
    wget
    git
    gh
    floorp-bin
    kitty
    nixfmt
    lazygit
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  time.timeZone = "Europe/Vienna";

  users.users.ldprg = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ]; # Add "wheel" for sudo access
    initialHashedPassword = "$y$j9T$7E7CHLLkmzKtzfxsAtd3M/$Iaa10xNFwBbTwNN9H/zwYfD3qN5zAE8Kle0vNtOe6mD"; # <-- This is where it goes!
    # home = "/home/nixos"; # Optional: Disko typically handles home subvolumes
  };

  console.keyMap = "de";

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}

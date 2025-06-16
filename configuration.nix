# Edit this configuration file to define what should be installed on

# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/networking.nix
      ./modules/wireguard-ui.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Automatic upgrades avec reboot si nécessaire
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = { lower = "01:00"; 
                     upper = "05:00"; };
    };
    
  nix = {
    gc = {
      automatic = true;
      options = "--max-freed 1G --delete-older-than 7d";
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos"; # Define your hostname.

  # Set your time zone.
   time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
   i18n.defaultLocale = "fr_FR.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "fr";
   };

  # Users
  users.groups.media = {};
  users.mutableUsers = false;  
  users.users.jujube = {
      isNormalUser = true;
      hashedPassword= "$6$Ga0j/waxtPBh0w7s$j97mI1dbgVPyEhWTReGJEvtZg0J5vSqNglp/Wc4TgdnM/3oKUcbxaDM/w4IG0LDnK9q/o39YNzPYCOKnf4VI11";		
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
    };

  security.sudo.enable = true;
  security.sudo.extraRules = [
  {  users = [ "jujube" ];
    commands = [
    { command = "ALL" ;
      options= [ "NOPASSWD" ]; 
    }];}
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    btop
    ranger	
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

    services.adguardhome = {
    enable = true;
    port = 3000;
    settings = {
      trusted_proxies = "127.0.0.1";
    };
  };

  services.vaultwarden = {
    enable = true;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
    };
  };


  # git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      user.name = "Symplectichien";
      user.email = "juke27flan@gmail.com";
    };
  };


# Qbitorroent headless
  users.users.qbit = {
    isSystemUser = true;
    createHome = true;
    home = "/var/lib/qbittorrent";
    group = "media"; };
  systemd = {
    packages = [pkgs.qbittorrent-nox];
    services."qbittorrent-nox@qbit" = {
      enable = true;
      overrideStrategy = "asDropin";
      wantedBy = ["multi-user.target"];
      serviceConfig.UMask = "002";
    };
  };


  # VSC server patch
  programs.nix-ld.enable = true;

# Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    openFirewall = true;
  };



  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
  system.stateVersion = "25.05"; 

}


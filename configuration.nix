# Edit this configuration file to define what should be installed on

# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
   time.timeZone = "Europe/Paris";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n.defaultLocale = "fr_FR.UTF-8";
   console = {
     font = "Lat2-Terminus16";
     keyMap = "fr";
   };
 users.groups.media = {};
 users.mutableUsers = false;  
 users.users.jujube = {
     isNormalUser = true;
     hashedPassword= "$y$j9T$btoXIJTx3euMz7hmiFXkA0$2gCWPEtJHMnlkKuFbKWc/B4dqGhuxpRzC/p3vmdnXS4";		
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


services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # other Nginx options

    virtualHosts."adguard.jujube" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
      };
    };

     virtualHosts."qbit.jujube" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
      };
    };

     virtualHosts."jelly.jujube" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
      };
    };

     virtualHosts."vault.jujube" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8222";
      };
    };

};

security.acme = {
  acceptTerms = true;
  defaults.email = "caca@pipi.com";
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

  # git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      user.name = "Symplectichien";
      user.email = "juke27flan@gmail.com";
    };
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # VSC server patch
  programs.nix-ld.enable = true;

# Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    openFirewall = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 443 80 53];
  networking.firewall.allowedUDPPorts = [ 53 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;


  networking.interfaces.enp2s0.ipv4.addresses = [ {
    address = "192.168.1.201";
    prefixLength = 24;
  } ];

 #   networking.interfaces.enp2s0.ipv6.addresses = [ {
  #  address = "41aa:e4fc:cb2f:8576:39ac:1871:2ef0:a48b";
 #   prefixLength = 64;
 # } ];


  networking.defaultGateway = "192.168.1.254";

  




  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}


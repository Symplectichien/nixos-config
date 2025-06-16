{ config, lib, pkgs, ... }:

{

# Nginx et Reverse proxy
services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  

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


  # git
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      user.name = "Symplectichien";
      user.email = "juke27flan@gmail.com";
    };
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

  networking.defaultGateway = "192.168.1.254";







}
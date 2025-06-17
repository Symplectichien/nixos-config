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

    virtualHosts."wgui.jujube" =  {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5012";
      };
    };

    virtualHosts."prowlarr.jujube" =  {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:9696";
          };
        };

    virtualHosts."radarr.jujube" =  {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:7878";
          };
        };
    




};

security.acme = {
  acceptTerms = true;
  defaults.email = "caca@pipi.com";
};

# vpn
networking.nat = {
    enable = true;
    enableIPv6 = true;
    externalInterface = "enp2s0";
    internalInterfaces = [ "wg0" ];
  };

networking.wg-quick.interfaces.wg0.configFile = config.services.wireguard-ui.configDir + "/wg0.conf";

services.wireguard-ui = {
   enable = true;
   port = 5012;
}; 



# Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 443 80 53];
  networking.firewall.allowedUDPPorts = [ 53 51820 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;


  networking.interfaces.enp2s0.ipv4.addresses = [ {
    address = "192.168.1.201";
    prefixLength = 24;
  } ];

  networking.defaultGateway = "192.168.1.254";







}
{
  inputs,
  config,
  pkgs,
  pkgs-unstable,
  system,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    ;
  cfg = config.taconic.nginx-proxy;
in
{

  options = {
    taconic.nginx-proxy.enable = lib.mkEnableOption "Enable Taconic nginx proxy module";
    taconic.nginx-proxy.acme-email = mkOption {
      type = types.str;
      description = "The email to use for Let's Encrypt certificates acquired via acme";
      default = config.taconic.admin-email;
    };
  };

  config = mkIf cfg.enable {

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";
      appendHttpConfig = ''
        log_format json_combined escape=json '{'
          '"http_host":"$host",'
          '"server_addr":"$server_addr",'
          '"server_port":"$server_port",'
          '"scheme":"$scheme",'
          '"port":"$server_port",'
          '"time_local":"$time_local",'
          '"remote_addr":"$remote_addr",'
          '"request_method":"$request_method",'
          '"request_uri":"$request_uri",'
          '"status": "$status",'
          '"body_bytes_sent":"$body_bytes_sent",'
          '"http_referer":"$http_referer",'
          '"http_user_agent":"$http_user_agent",'
          '"request_time":"$request_time",'
          '"upstream_response_time":"$upstream_response_time",'
          '"upstream_addr":"$upstream_addr",'
          '"upstream_status":"$upstream_status"'
        '}';
        error_log /var/log/nginx/error.log warn;
        access_log /var/log/nginx/access.json json_combined;
      '';
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = config.taconic.nginx-proxy.acme-email;
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}

{
  inputs,
  config,
  pkgs,
  system,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkDefault
    mkIf
    types
    ;
  cfg = config.taconic.network-monitor;
in
{

  options = {

    taconic.network-monitor = {
      enable = mkEnableOption "Enable Taconic network monitor module";
      flows.enable = mkOption {
        type = types.bool;
        description = "Enables network flow logging.";
        default = true;
      };
      alerts.enable = mkOption {
        type = types.bool;
        description = "Enables network IDS alert logging.";
        default = true;
      };
      homeNet = mkOption {
        type = types.str;
        description = "Home Network CIDR";
        example = "192.168.1.1/24";
      };
      interface = mkOption {
        type = types.str;
        description = "Interface to sniff";
        default = config.taconic.internalInterface;
      };
    };
  };

  config = mkIf cfg.enable {

    services.suricata = {
      enable = true;
      settings = {
        unix-command.enabled = true;
        outputs = [
          {
            eve-log = {
              enabled = cfg.flows.enable;
              types = [ { flow.enabled = true; } ];
              filename = "eve-flow.json";
            };
          }
          {
            eve-log = {
              enabled = cfg.alerts.enable;
              types = [ { alert.enabled = true; } ];
              filename = "eve-alerts.json";
            };
          }
        ];
        af-packet = [ { interface = cfg.interface; } ];
        classification-file = "${pkgs.suricata}/etc/suricata/classification.config";
      };
      disabledRules = [
        "group:modbus-events.rules"
        "group:dnp3-events.rules"
      ];
    };

    # logrotation is needed
    services.logrotate.enable = true;
    services.logrotate.settings."/var/log/suricata/eve-flow.json" = {
      frequency = "daily";
      rotate = 3;
      missingok = true;
      compress = true;
      delaycompress = true;
      postrotate = "/run/current-system/sw/bin/suricatasc -c reopen-log-files /var/run/suricata/suricata-command.socket";
    };
    services.logrotate.settings."/var/log/suricata/eve-alerts.json" = {
      frequency = "daily";
      rotate = 3;
      missingok = true;
      compress = true;
      delaycompress = true;
      postrotate = "/run/current-system/sw/bin/suricatasc -c reopen-log-files /var/run/suricata/suricata-command.socket";
    };

    # quality of life tools
    environment.systemPackages = [
      pkgs.suricata
      pkgs.ethtool
      pkgs.jq
    ];
  };
}

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
    mkIf
    types
    ;
  cfg = config.taconic.log-server;
in
{

  options = {
    taconic.log-server.enable = mkEnableOption "Enable Taconic log server";
    taconic.log-server.collectionIp = mkOption {
      type = types.str;
      description = "The IP that log collection and aggregation services listen on.";
      default = config.taconic.internalIp;
    };
  };

  config = mkIf cfg.enable {
    # we need the nginx proxy to expose various services on local
    # ports to our network.

    taconic.nginx-proxy.enable = true;
    # MONITORING: services run on loopback interface
    #             nginx reverse proxy exposes services to network
    #             - grafana:3010
    #             - prometheus:3020
    #             - loki:3030
    #             - promtail:3031

    # prometheus: port 3020 (8020)
    #
    services.prometheus = {
      port = 3020;
      listenAddress = "127.0.0.1";
      enable = true;

      exporters = {
        node = {
          port = 3021;
          enabledCollectors = [ "systemd" ];
          enable = true;
        };
      };

      # ingest the published nodes
      scrapeConfigs = [
        {
          job_name = "nodes";
          static_configs = [
            # our local node export
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          ];
        }
      ];
    };

    # loki: port 3030 (8030)
    #
    services.loki = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3030;
          http_listen_address = "127.0.0.1";
        };
        auth_enabled = false;

        common = {
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
          replication_factor = 1;
          path_prefix = "/tmp/loki";
        };

        # The compactor is needed to enable expiry after retention
        # period.
        compactor = {
          working_directory = "/var/lib/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 100;
          delete_request_store = "filesystem";
        };
        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          filesystem = {
            directory = "/var/lib/loki/chunks";
          };
        };

        limits_config = {
          # 31 day retention is default
          retention_period = "744h";
        };

      };
      # user, group, dataDir, extraFlags, (configFile)
    };

    # promtail: port 3031 (8031)
    #
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          }
        ];
        scrape_configs = [
          {
            job_name = "journal";
            journal = {
              max_age = "12h";
              labels = {
                job = "systemd-journal";
                host = config.networking.hostName;
              };
            };
            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
            ];
          }
        ];
      };
      # extraFlags
    };

    # grafana: port 3010 (8010)
    #
    services.grafana = {
      enable = true;

      settings = {
        server = {
          protocol = "http";
          http_port = 3010;
          http_addr = "127.0.0.1";
          #rootUrl = "http://:8010"; # helps with nginx / ws / live
        };
        #analytics.reporting.enable = false;

      };
      # WARNING: this should match nginx setup!
      # prevents "Request origin is not authorized"

      provision = {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          }
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
          }
        ];
      };
    };

    services.nginx.upstreams = {
      "grafana" = {
        servers = {
          "127.0.0.1:${toString config.services.grafana.settings.server.http_port}" = { };
        };
      };
      "prometheus" = {
        servers = {
          "127.0.0.1:${toString config.services.prometheus.port}" = { };
        };
      };
      "loki" = {
        servers = {
          "127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}" = { };
        };
      };
      "promtail" = {
        servers = {
          "127.0.0.1:${toString config.services.promtail.configuration.server.http_listen_port}" = { };
        };
      };
    };

    # nginx reverse proxy
    services.nginx = {

      virtualHosts.grafana = {
        locations."/" = {
          proxyPass = "http://grafana";
          proxyWebsockets = true;
        };
        listen = [
          {
            addr = cfg.collectionIp;
            port = 8010;
          }
        ];
      };

      virtualHosts.prometheus = {
        locations."/".proxyPass = "http://prometheus";
        listen = [
          {
            addr = cfg.collectionIp;
            port = 8020;
          }
        ];
      };

      # confirm with http://192.168.1.10:8030/loki/api/v1/status/buildinfo
      #     (or)     /config /metrics /ready
      virtualHosts.loki = {
        locations."/".proxyPass = "http://loki";
        listen = [
          {
            addr = cfg.collectionIp;
            port = 8030;
          }
        ];
      };

      virtualHosts.promtail = {
        locations."/".proxyPass = "http://promtail";
        listen = [
          {
            addr = cfg.collectionIp;
            port = 8031;
          }
        ];
      };
    };

    # allow access to log services
    networking.firewall.allowedTCPPorts = [
      8010
      8020
      8030
      8031
    ];

  };

}

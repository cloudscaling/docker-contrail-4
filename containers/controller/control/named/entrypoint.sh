#!/bin/bash

source /common.sh

cat > /etc/contrail/dns/contrail-named.conf << EOM
options {
    directory "/etc/contrail/dns/";
    managed-keys-directory "/etc/contrail/dns/";
    empty-zones-enable no;
    pid-file "/etc/contrail/dns/contrail-named.pid";
    session-keyfile "/etc/contrail/dns/session.key";
    listen-on port 53 { any; };
    allow-query { any; };
    allow-recursion { any; };
    allow-query-cache { any; };
    max-cache-size 32M;
};

key "rndc-key" {
    algorithm hmac-md5;
    secret "$RNDC_KEY";
};

controls {
    inet 127.0.0.1 port 8094
    allow { 127.0.0.1; }  keys { "rndc-key"; };
};

logging {
    channel debug_log {
        file "/var/log/contrail/contrail-named.log" versions 3 size 5m;
        severity debug;
        print-time yes;
        print-severity yes;
        print-category yes;
    };
    category default {
        debug_log;
    };
    category queries {
        debug_log;
    };
};
EOM

chown contrail:contrail /etc/contrail/dns/contrail-named.conf
touch /var/log/contrail/contrail-named.log
chown contrail:contrail /var/log/contrail/contrail-named.log
chown contrail:contrail /var/log/contrail

set_third_party_auth_config
set_vnc_api_lib_ini

exec "$@"

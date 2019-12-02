#!/usr/bin/with-contenv bash

rm /config/.config-lock
/usr/bin/flexget -c /config/config.yml --loglevel debug web passwd "flexget ui password"
/usr/bin/flexget -c /config/config.yml --loglevel debug daemon start --autoreload-config

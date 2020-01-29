#!/bin/bash
if [ -n "$XDEBUG" ];
then
    inifile="/usr/local/etc/php/conf.d/pecl-xdebug.ini"
    extfile="$(find /usr/local/lib/php/extensions/ -name xdebug.so)";
    remote_port="${XDEBUG_REMOTE_PORT:-9000}";
    idekey="${XDEBUG_IDEKEY:-xdbg}";

    if [ -f "$extfile" ] && [ ! -f "$inifile" ];
    then
        {
            echo "[Xdebug]";
            echo "zend_extension=${extfile}";
            echo "xdebug.idekey=${idekey}";
            echo "xdebug.remote_enable=1";
            echo "xdebug.remote_connect_back=1";
            echo "xdebug.remote_autostart=1";
            echo "xdebug.remote_port=${remote_port}";
        } > $inifile;
    fi

    unset extfile remote_port idekey;
fi

# Ajust database config

if [[ $OJS_DB_HOST != localhost ]]; then
   sed -i 's/host = localhost/host = '$OJS_DB_HOST'/' /var/www/html/config.inc.php
fi

if [[ $OJS_DB_USER != ojs ]]; then
   sed -i 's/user = ojs/user = '$OJS_DB_USER'/' /var/www/html/config.inc.php
fi

if [[ $OJS_DB_PASSWORD != ojs ]]; then
   sed -i 's/password = ojs/password = '$OJS_DB_PASSWORD'/' /var/www/html/config.inc.php
fi

if [[ $OJS_DB_NAME != ojs ]]; then
   sed -i 's/name = ojs/name = '$OJS_DB_NAME'/' /var/www/html/config.inc.php
fi

chown  www-data:www-data /var/www/html/config.inc.php

exec "$@"

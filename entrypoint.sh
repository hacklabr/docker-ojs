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

if [[ ! -z $OJS_SMTP_ENABLE ]]; then
   sed  -i 's/; smtp = On/ smtp = '$OJS_SMTP_ENABLE'/'  /var/www/html/config.inc.php

   if [[ $OJS_SMTP_ENABLE != Off ]]; then
      sed  -i 's/; smtp_server = mail.example.com/ smtp_server = '$OJS_SMTP_SERVER'/'  /var/www/html/config.inc.php 
      sed  -i 's/; smtp_port = 25/ smtp_port = '$OJS_SMTP_PORT'/'  /var/www/html/config.inc.php 
      sed  -i 's/; smtp_username = username/ smtp_username = '$OJS_SMTP_USERNAME'/'  /var/www/html/config.inc.php 
      sed  -i 's/; smtp_password = password/ smtp_password = '$OJS_SMTP_PASSWORD'/'  /var/www/html/config.inc.php 
      sed  -i 's/; allow_envelope_sender = Off/ allow_envelope_sender = On/'  /var/www/html/config.inc.php 
      sed  -i 's/; force_default_envelope_sender = Off/ force_default_envelope_sender = On/'  /var/www/html/config.inc.php 
      sed  -i 's/; force_dmarc_compliant_from = Off/ force_dmarc_compliant_from = On/'  /var/www/html/config.inc.php 
      sed  -i 's/; default_envelope_sender = my_address@my_host.com/ default_envelope_sender = '$OJS_DEFAULT_MAIL_SENDER'/'  /var/www/html/config.inc.php 

      # Check TLS or SSL enlabled
      if [[ -z $OJS_SMTP_ATUH ]] && [[ $OJS_SMTP_AUTH == ssl ]]; then
         sed  -i 's/; smtp_auth = ssl/ smtp_auth = ssl/'  /var/www/html/config.inc.php 
      else
         sed  -i 's/; smtp_auth = ssl/ smtp_auth = '$OJS_SMTP_AUTH'/'  /var/www/html/config.inc.php 
      fi
   fi
fi

if [[ ! -z $OJS_INSTALLED_STATE ]]; then
   sed -i 's/installed = .*/installed = '$OJS_INSTALLED_STATE'/'  /var/www/html/config.inc.php
fi

chown  www-data:www-data /var/www/html/config.inc.php

exec "$@"

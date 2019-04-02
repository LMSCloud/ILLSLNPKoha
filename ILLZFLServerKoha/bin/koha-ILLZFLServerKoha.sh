#!/bin/sh
#
# koha-ILLZFLServerKoha.sh -- start/stop ILLZFLServerKoha server for named Koha instances
#
# Copyright 2018-2019 (C) LMSCLoud GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

# Read configuration variable file if it is present
[ -r /etc/default/koha-common ] && . /etc/default/koha-common

# include helper functions
if [ -f "/usr/share/koha/bin/koha-functions.sh" ]; then
    . "/usr/share/koha/bin/koha-functions.sh"
else
    echo "Error: /usr/share/koha/bin/koha-functions.sh not present." 1>&2
    exit 1
fi

action="$1"
shift
if [ $action != 'start' -a $action != 'stop' ]
then
    echo "possible actions: start | stop (but not '${action}')" > /dev/stderr
    exit 1
else
    for name in "$@"
    do
        if [ ! -e /etc/koha/sites/${name}/koha-conf.xml ] ;
        then
            echo "No such instance: ${name}" > /dev/stderr
            continue;
        fi
        [ -e /etc/koha/sites/${name}/ILLZFLServerKoha.conf ] || continue

        if [ $action = 'start' ]
        then
            echo "Starting ILLZFLServerKoha server for $name"

            mkdir -p /var/run/koha/${name}
            chown "${name}-koha:${name}-koha" /var/run/koha/${name}

            adjust_paths_dev_install $name
            PERL5LIB=/usr/share/koha/lib/Koha/Illbackends/ILLSLNPKoha/ILLZFLServerKoha:/usr/share/koha:$PERL5LIB
            export KOHA_CONF PERL5LIB
            KOHA_CONF=/etc/koha/sites/${name}/koha-conf.xml
            # PERL5LIB has been read already
            if [ "$DEV_INSTALL" = "" ]; then
                LIBDIR=$KOHA_HOME/lib
            else
                LIBDIR=$KOHA_HOME
            fi

            daemon \
                --name="$name-koha-ILLZFLServerKoha" \
                --errlog="/var/log/koha/$name/runILLZFLServerKoha-error.log" \
                --stdout="/var/log/koha/$name/runILLZFLServerKoha.log" \
                --output="/var/log/koha/$name/runILLZFLServerKoha-output.log" \
                --verbose=1 \
                --respawn \
                --delay=30 \
                --pidfiles="/var/run/koha/${name}" \
                --user="$name-koha.$name-koha" \
                -- \
                "/usr/share/koha/lib/Koha/Illbackends/ILLSLNPKoha/ILLZFLServerKoha/bin/runILLZFLServerKoha.pl" \
                "/etc/koha/sites/${name}/ILLZFLServerKoha.conf"
            
        else    # $action = 'stop'
            echo "Stopping ILLZFLServerKoha server for $name"
            daemon \
                --name="$name-koha-ILLZFLServerKoha" \
                --errlog="/var/log/koha/$name/runILLZFLServerKoha-error.log" \
                --stdout="/var/log/koha/$name/runILLZFLServerKoha.log" \
                --output="/var/log/koha/$name/runILLZFLServerKoha-output.log" \
                --verbose=1 \
                --respawn \
                --delay=30 \
                --pidfiles="/var/run/koha/${name}" \
                --user="$name-koha.$name-koha" \
                --stop
        fi
    done
fi

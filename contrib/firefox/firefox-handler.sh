#!/bin/sh

# firefox settings (about:config)
#
# network.protocol-handler.app.tcpdump       string   /path/to/firefox-handler.sh
# network.protocol-handler.external.tcpdump  boolean  true
# network.protocol-handler.app.iftop         string   /path/to/firefox-handler.sh
# network.protocol-handler.external.iftop    boolean  true
# network.protocol-handler.app.ssh           string   /path/to/firefox-handler.sh
# network.protocol-handler.external.ssh      boolean  true
# network.protocol-handler.app.telnet        string   /path/to/firefox-handler.sh
# network.protocol-handler.external.telnet   boolean  true

PROTO=`echo $1 | egrep -o ^[a-z]+`
ARG=`echo $1 | sed 's/^[a-z]*:\/*//' | tr -cd "a-zA-Z0-9._-"`

echo "proto=$PROTO arg=$ARG"

if [ "$PROTO" = ssh ]; then
    urxvt -T "ssh $ARG" -e ssh $ARG
elif [ "$PROTO" = telnet ]; then
    urxvt -T "telnet $ARG" -e telnet $ARG
elif [ "$PROTO" = tcpdump ]; then
    IFACE=`echo $ARG | egrep -o "^[^-_]+"`
    HOST=`echo $ARG | egrep -o "[-_][0-9.]+" | tr -d "_-"`
    urxvt -T "tcpdump -- $IFACE -- host $HOST" -e ssh -t orbitel.ru ~/bin/zsh_tcpdump.sh $IFACE $HOST
elif [ "$PROTO" = iftop ]; then
    IFACE=`echo $ARG | egrep -o "^[^-_]+"`
    HOST=`echo $ARG | egrep -o "[-_][0-9.]+" | tr -d "_-"`
    urxvt -T "iftop -- $IFACE -- host $HOST" -e ssh -t orbitel.ru ~/bin/zsh_iftop.sh $IFACE $HOST
fi

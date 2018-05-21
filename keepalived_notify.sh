#!/bin/bash
#keepalived script for glusterd

master() {
    /etc/init.d/glusterd status
    if [ $? -ne 0 ];then
        /etc/init.d/glusterd start
    else
        /etc/init.d/glusterd restart
    fi
}

backup() {
    /etc/init.d/glusterd status
    if [ $? -ne 0 ];then
        /etc/init.d/glusterd start
    fi
}

case $1 in
    master)
        master
    ;;
    backup)
        backup
    ;;
    fault)
        backup
    ;;
    stop)
        backup
        /etc/init.d/keepalived restart &>/dev/null
    ;;
    *)
        echo $"Usage: $0 {master|backup|fault|stop}"
esac


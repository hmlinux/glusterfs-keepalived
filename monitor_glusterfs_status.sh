#!/bin/bash
#check glusterfsd and glusterd process

/etc/init.d/glusterd status &>/dev/null
if [ $? -eq 0 ];then
    /etc/init.d/glusterfsd status &>/dev/null
    if [ $? -eq 0 ];then
        exit 0
    else
        exit 2
    fi
else
    /etc/init.d/glusterd start &>/dev/null
    pkill keepalived &>/dev/null && exit 1
fi

#!/bin/bash
for user in `awk -F: '($3 < 500) {print $1 }' /etc/passwd`; do
    if [ $user != "root" ]
        then
        /usr/sbin/usermod -L $user
        if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ]
        then
            /usr/sbin/usermod -s /usr/sbin/nologin $user
        fi
    fi
done

# awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && 
# $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && 
# $7!="'"$(which nologin)"'" && $7!="/bin/false") {print $1}' /etc/passwd |
# while read user do usermod -s $(which nologin) $user done
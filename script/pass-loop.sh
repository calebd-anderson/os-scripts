#!/bin/bash
users=$(getent passwd {1000..6000} | cut -d ":" -f 1)
for user in $users; do
  read -p "enter pass ("${user}"): " pass
  echo "$user:$pass" | chpasswd
  echo "$user:$pass" >> fedora_users.csv
done

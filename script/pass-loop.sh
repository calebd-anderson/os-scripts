#!/bin/bash
users=$(getent passwd {1000..6000} | cut -d ":" -f 1)
for user in $users; do
  # give random 8 char password
  pass=$(openssl rand -base64 6)
  echo "$user:$pass" | chpasswd
  echo "$user:$pass" >> fedora_users.csv
  # set shell to nologin
  /usr/sbin/usermod -s /usr/sbin/nologin $user
done

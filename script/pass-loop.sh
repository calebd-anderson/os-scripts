#!/bin/bash
users=$(getent passwd {1000..6000} | cut -d ":" -f 1)
for user in $users; do
  pass=$(openssl rand -base64 6)
  echo "$user:$pass" | chpasswd
  echo "$user:$pass" >> fedora_users.csv
done

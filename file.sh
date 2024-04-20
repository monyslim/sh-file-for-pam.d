#!/bin/bash

## create users
username1="kenuser"
username2="jamesuser"

# Create kenuser with password
sudo adduser --disabled-password --gecos "" $username1
echo "$username1:passwd1" | sudo chpasswd

# Create jamesuser with password
sudo adduser --disabled-password --gecos "" $username2
echo "$username2:passwd2" | sudo chpasswd

# Add users to nosu group
sudo groupadd "nosu"
sudo usermod -aG nosu $username1
sudo usermod -aG nosu $username2

## prevent the user from using su
sudo chown $USER /etc/pam.d/su
sudo rm -f /etc/pam.d/su
sudo touch /etc/pam.d/su
sudo chown $USER /etc/pam.d/su

echo auth       sufficient pam_rootok.so >> /etc/pam.d/su
echo auth       required   pam_wheel.so deny group=nosu >> /etc/pam.d/su
echo session       required   pam_env.so readenv=1 >> /etc/pam.d/su
echo session       required   pam_env.so readenv=1 envfile=/etc/default/locale >> /etc/pam.d/su
echo session    optional   pam_mail.so nopen >> /etc/pam.d/su
echo session    required   pam_limits.so >> /etc/pam.d/su
echo @include common-auth >> /etc/pam.d/su
echo @include common-account >> /etc/pam.d/su
echo @include common-session >> /etc/pam.d/su

# Update SSH configuration
File="/etc/ssh/sshd_config"
Temp_file="temp_settings"

if [[ -f $Temp_file ]]; then
    rm -f $Temp_file
fi    

touch $Temp_file

while read -r line; do
    current_line=$(echo $line | grep "PasswordAuthentication no")
    if [[ $current_line ]]; then
        echo "PasswordAuthentication yes" >> $Temp_file
    else
        echo $line >> $Temp_file
    fi
done < $File

sudo cp $File /etc/ssh/sshd_config.bak
sudo rm -f $File
sudo mv $Temp_file $File
sudo systemctl restart ssh

#!/bin/bash
#untar splunk
tar -xvf /data/splunk/splunk-7* -C /opt
#ip=$(zenity --entry --title="Master Application Server IP" --text="IP Adress:")
#sed -i "s/10.0.0.10/$ip/g" splunk_master.sh
#firewall
#firewall-cmd --add-port 8089/tcp --permanent
firewall-cmd --add-port 9997/tcp --permanent
firewall-cmd --add-port 8000/tcp --permanent
systemctl restart firewalld
hostnamectl set-hostname splunk-sensor
#deploy splunk and build file structure
/opt/splunk/bin/./splunk start --accept-license --no-prompt --answer-yes
#add a defaut splunk user so that you can run splunk not as roor
useradd -r -d /opt/splunk/ splunk
/opt/splunk/bin/./splunk stop
#edit the generic password
/opt/splunk/bin/./splunk edit user admin -password overlord -auth admin:changeme
#sets splunk up to start on boot as user splunk
/opt/splunk/bin/./splunk enable boot-start -user splunk
#sets splunk to start as with only HTTPS connections
touch /opt/splunk/etc/system/local/web.conf
echo [settings] > /opt/splunk/etc/system/local/web.conf
echo enableSplunkWebSSL = 1 >> /opt/splunk/etc/system/local/web.conf
cp /data/splunk/deployment-apps/nerdsensor/default/outputs.conf
#cp /tmp/local/serverclass.conf /opt/splunk/etc/system/local/
#cp /tmp/local/server.conf /opt/splunk/etc/system/local/
#cp -r /tmp/deployment-apps/* /opt/splunk/etc/deployment-apps/
#changes the default login for the first time so that it doesn't ask you to change your password
touch /opt/splunk/etc/.ui_login
#splunk now owns all splunk files...installed as root
chown -R splunk /opt/splunk
/opt/splunk/bin/./splunk start
#sudo -u splunk /opt/splunk/bin/./splunk set deploy-poll 10.0.0.10:8089 -auth admin:overlord


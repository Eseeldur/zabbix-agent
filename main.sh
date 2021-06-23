#!/bin/bash
#
# Created and last edited alekseyolg - 20210622
#
# Centos 6-8
#
##########################################################################################################################
#

# Displaying the progress of the current task

function installation_process () {
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
echo "install" $1
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
echo "----------------------------------------------------------------"
}

##########################################################################################################################

# Select version OS (Only Centos 6-8) and select package manager (yum or dnf)

release=$(cat /etc/redhat-release | sed 's/[^0-9.]*//g')
release=${release:0:1};
if [ "$release" = 8 ]; then
    packet_manage=dnf
elif [ "$release" = 7 ] || [ "$release" = 6 ]; then
    packet_manage=yum
else
echo "This system is not supported this script! Please, install zabbix manually"
sleep 3
exit 1
fi

##########################################################################################################################

# Install rpm-package and sysstat

$packet_manage -y install https://repo.zabbix.com/zabbix/5.0/rhel/"$release"/x86_64/zabbix-agent-5.0.1-1.el"$release".x86_64.rpm sysstat
sed -i 's/^\#\ Timeout=3/Timeout=20/' /etc/zabbix/zabbix_agentd.conf
else
sed -i 's/^ServerActive=127.0.0.1/ServerActive=zbx.bars-open.ru/' /etc/zabbix/zabbix_agentd.conf
fi

##########################################################################################################################

# Make directory for zabbix-scripts

mkdir --mode 771 /etc/zabbix/zabbix_scripts
chown zabbix.zabbix /etc/zabbix/zabbix_scripts
installation_process "Make directory for scripts"
cp ./HDD_iostat.sh /etc/zabbix/zabbix_scripts/HDD_iostat.sh
chmod 0755 /etc/zabbix/zabbix_scripts/HDD_iostat.sh
chown zabbix.zabbix /etc/zabbix/zabbix_scripts/HDD_iostat.sh
cat >> /etc/zabbix/zabbix_agentd.conf << END 
UserParameter=discovery_part, df -P |grep '^/dev'| grep -v '/boot' | awk 'BEGIN {count=0;array[0]=0;} {array[count]=\$6;count=count+1;} END {printf("{\n\t\"data\":[\n");for(i=0;i<count;++i){printf("\t\t{\n\t\t\t\"{#PARTITION}\":\"%s\"}", array[i]); if(i+1<count){printf(",\n");}} printf("]}\n");}'
UserParameter=discovery_disk, iostat -dN | awk 'BEGIN {check=0;count=0;array[0]=0;} {if(check==1 && $1 != ""){array[count]=$1;count=count+1;}if($1=="Device:"){check=1;}} END {printf("{\n\t\"data\":[\n");for(i=0;i<count;++i){printf("\t\t{\n\t\t\t\"{#HARDDISK}\":\"%s\"}", array[i]); if(i+1<count){printf(",\n");}} printf("]}\n");}'
UserParameter=HDD.iostat[*], /etc/zabbix/zabbix_scripts/HDD_iostat.sh "\$1" "\$2"
END

##########################################################################################################################

# Install special metrics for database Oracle

function ORACLE {
scp ./ash_wait.sh oracle_monitoring.sh /etc/zabbix/zabbix_scripts
chmod 0744 /etc/zabbix/zabbix_scripts/ash_wait.sh
chmod 0744 /etc/zabbix/zabbix_scripts/oracle_monitoring.sh
chown oracle.oinstall /etc/zabbix/zabbix_scripts/ash_wait.sh
chown oracle.oinstall /etc/zabbix/zabbix_scripts/oracle_monitoring.sh
cat >> /etc/zabbix/zabbix_agentd.conf << END
UserParameter=oracle_monitoring[*], sudo -u oracle /etc/zabbix/zabbix_scripts/oracle_monitoring.sh "\$1" "\$2"
UserParameter=ash[*], sudo -u oracle /etc/zabbix/zabbix_scripts/ash_wait.sh "\$1"
END
}

##########################################################################################################################

# Install special metrics for web-server Apache

function APACHE {
scp ./apache-stats.sh /etc/zabbix/zabbix_scripts
chmod 0744 /etc/zabbix/zabbix_scripts/apache-stats.sh
chown zabbix.zabbix /etc/zabbix/zabbix_scripts/apache-stats.sh
cat >> /etc/zabbix/zabbix_agentd.conf << END 
UserParameter=apache2[*], /etc/zabbix/zabbix_scripts/apache-stats.sh "none" "\$1" "\$2"
END
cat >> /etc/httpd/conf/httpd.conf << END 
$(BUF=$(grep "^LoadModule info_module modules/mod_info.so" /etc/httpd/conf/httpd.conf); if [[ -z $BUF ]]; then
echo "LoadModule info_module modules/mod_info.so"; fi) 
$(BUF=$(grep "^LoadModule status_module modules/mod_status.so" /etc/httpd/conf/httpd.conf); if [[ -z $BUF ]]; then
echo "LoadModule status_module modules/mod_status.so"; fi) 
ExtendedStatus On 
<Location /server-status>
SetHandler server-status
Order Deny,Allow
Deny from all
Allow from 127.0.0.1
</Location>
END
service httpd restart
}

##########################################################################################################################

# Install special metrics for web-server Nginx

function NGINX {
mv ./nginx-stats.sh /etc/zabbix/zabbix_scripts
chmod 0744 /etc/zabbix/zabbix_scripts/nginx-stats.sh
chown zabbix.zabbix /etc/zabbix/zabbix_scripts/nginx-stats.sh
cat >> /etc/zabbix/zabbix_agentd.conf << END
UserParameter=nginx[*],/etc/zabbix/zabbix_scripts/nginx-stats.sh "\$1" "\$2"
END

##########################################################################################################################

# Install special metrics for database Postgres

function POSTGRES {
scp ./postgresql.conf /etc/zabbix/zabbix_agentd.d
mkdir /var/lib/zabbix
cat >> /var/lib/zabbix/.pgpass << END
127.0.0.1:*:*:postgres:postgres
END
chmod 0644 /etc/zabbix/zabbix_agentd.d/postgresql.conf
chown zabbix.zabbix /etc/zabbix/zabbix_agentd.d/postgresql.conf
chmod 600 /var/lib/zabbix/.pgpass
chown zabbix.zabbix /var/lib/zabbix/.pgpass
echo Скрипт мониторинга мониторинга БД Postgres установлен!
}

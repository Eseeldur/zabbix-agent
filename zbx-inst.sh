#!/bin/bash
function BASIC {
release=$(cat /etc/redhat-release | sed 's/[^0-9.]*//g')
release=${release:0:1};
if [ "$release" = 8 ]; then
packet_manage=dnf
elif [ "$release" = 7 ] || [ "$release" = 6 ]; then
packet_manage=yum
else
echo Ваша операционная система не поддерживается данным скриптом!/nВыполнение скрипта завершено!
exit
fi
echo Установка Zabbix-agent
$packet_manage -y install https://repo.zabbix.com/zabbix/5.0/rhel/"$release"/x86_64/zabbix-agent-5.0.3-1.el"$release".x86_64.rpm sysstat
sed -i 's/^\#\ Timeout=3/Timeout=20/' /etc/zabbix/zabbix_agentd.conf
echo Нажмите \'Enter\' если используете для мониторинга сервер zbx.bars-open.ru или введите свой:
read ServerName
if [ -z "$ServerName" ]; then
sed -i 's/^Server=127.0.0.1/Server=zbx.bars-open.ru/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=127.0.0.1/ServerActive=zbx.bars-open.ru/' /etc/zabbix/zabbix_agentd.conf
else
sed -i 's/^Server=127.0.0.1/Server='"$ServerName"'/' /etc/zabbix/zabbix_agentd.conf
sed -i 's/^ServerActive=127.0.0.1/ServerActive='"$ServerName"'/' /etc/zabbix/zabbix_agentd.conf
fi
echo Введите имя сервера для мониторинга
read Hostname
sed -i 's/^Hostname=Zabbix\ server/Hostname='"$Hostname"'/' /etc/zabbix/zabbix_agentd.conf
mkdir --mode 771 /etc/zabbix/zabbix_scripts
chown zabbix.zabbix /etc/zabbix/zabbix_scripts
echo Создана директория для скриптов!!!
cp ./HDD_iostat.sh /etc/zabbix/zabbix_scripts/HDD_iostat.sh
chmod 0755 /etc/zabbix/zabbix_scripts/HDD_iostat.sh
chown zabbix.zabbix /etc/zabbix/zabbix_scripts/HDD_iostat.sh
cat >> /etc/zabbix/zabbix_agentd.conf << END 
UserParameter=discovery_part, df -P |grep '^/dev'| grep -v '/boot' | awk 'BEGIN {count=0;array[0]=0;} {array[count]=\$6;count=count+1;} END {printf("{\n\t\"data\":[\n");for(i=0;i<count;++i){printf("\t\t{\n\t\t\t\"{#PARTITION}\":\"%s\"}", array[i]); if(i+1<count){printf(",\n");}} printf("]}\n");}'
UserParameter=discovery_disk, iostat -dN | awk 'BEGIN {check=0;count=0;array[0]=0;} {if(check==1 && $1 != ""){array[count]=$1;count=count+1;}if($1=="Device:"){check=1;}} END {printf("{\n\t\"data\":[\n");for(i=0;i<count;++i){printf("\t\t{\n\t\t\t\"{#HARDDISK}\":\"%s\"}", array[i]); if(i+1<count){printf(",\n");}} printf("]}\n");}'
UserParameter=HDD.iostat[*], /etc/zabbix/zabbix_scripts/HDD_iostat.sh "\$1" "\$2"
END
echo "---------------------------------------------"
echo "---------------------------------------------"
echo Скрипт мониторинга жёстких дисков установлен!
echo "---------------------------------------------"
echo "---------------------------------------------"
}
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
echo "---------------------------------------------"
echo "---------------------------------------------"
echo Скрипты мониторинга мониторинга БД Oracle установлены!
echo "---------------------------------------------"
echo "---------------------------------------------"
}
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
echo Для окончания установки мониторинга Apache необходим его перезапуск.
echo Перезапустить сейчас?
echo Нажмите y если да, иначе любую клавишу.
read restart_apache
if [ "$restart_apache" = y ]; then
echo перезапуск Apache
if [ "$release" = 6 ]; then
service httpd restart
else
systemctl restart httpd
fi
fi
}
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
function NGINX {
scp ./nginx-stats.sh /etc/zabbix/zabbix_scripts
chmod 0744 /etc/zabbix/zabbix_scripts/nginx-stats.sh
chown zabbix.zabbix /etc/zabbix/zabbix_scripts/nginx-stats.sh
cat >> /etc/zabbix/zabbix_agentd.conf << END 
UserParameter=nginx[*],/etc/zabbix/zabbix_scripts/nginx-stats.sh "\$1" "\$2"
END
echo "---------------------------------------------"
echo "---------------------------------------------"
echo Скрипт мониторинга мониторинга Nginx установлен!
echo "---------------------------------------------"
echo "---------------------------------------------"
}
function MAIN {
echo Введите :
echo 1 - Базовые метрики
echo 2 - Oracle
echo 3 - Oracle+Apache
echo 4 - Oracle+Nginx
echo 5 - PostgreSQL
echo 6 - PostgreSQL+Apache
echo 7 - PostgreSQL+Nginx
echo 8 - Apache
echo 9 - Nginx
echo 10 - Redis
read number
if [ "$number" = 1 ]; then
BASIC;
elif [ "$number" = 2 ]; then
echo Установка метрик Oracle
BASIC
ORACLE
elif [ "$number" = 3 ]; then
echo Установка метрик Oracle+Apache
BASIC
ORACLE
APACHE
elif [ "$number" = 4 ]; then
echo Установка метрик Oracle+Nginx
BASIC
ORACLE
NGINX
elif [ "$number" = 5 ]; then
echo Установка метрик PostgreSQL
BASIC
POSTGRES
elif [ "$number" = 6 ]; then
echo Установка метрик PostgreSQL+Apache
BASIC
POSTGRES
APACHE
elif [ "$number" = 7 ]; then
echo Установка метрик PostgreSQL+Nginx
BASIC
POSTGRES
NGINX
elif [ "$number" = 8 ]; then
echo Установка метрик Apache
BASIC
APACHE
elif [ "$number" = 9 ]; then
echo Установка метрик Nginx
BASIC
NGINX
elif [ "$number" = 10 ]; then
echo Данный функционал пока не поддерживается скриптом!
else
echo Повторите ввод!
MAIN
fi
}
MAIN
service zabbix-agent start
echo "---------------------------------------------"
echo "---------------------------------------------"
echo Добавьте на Zabbix-server узел с именем "$Hostname"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo ".∧＿∧" 
echo "( ･ω･｡)つ━☆・*。" 
echo "⊂  ノ    ・゜+. "
echo "しーＪ   °。+ *´¨) "
echo "         .· ´¸.·*´¨) "
echo "          (¸.·´ (¸.·'* ☆ Конец работы скрипта"
echo "---------------------------------------------"
echo "---------------------------------------------"


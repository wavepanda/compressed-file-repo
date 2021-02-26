#!/bin/bash
#↓before using this script , run command bellow↓
#sed -i 's/\r//' linux_initial.sh    #use this to fix this script for linux

echo -e "\n+---------------------- checking hardware info -------------------+\n"
cat /proc/version &&cat /proc/cpuinfo|grep -E "model name|cpu cores" &&cat /proc/meminfo|grep MemTotal &&\
echo -e "\n///////////////// checking connectivity ///////////////////\n"
echo "`ip a|grep inet`"
sleep 1
echo -e "\n"
ping ntp1.aliyun.com -c 4 && \
echo -e "\n/////////////////// checking date ///////////////////\n"
date &&\sleep 1s &&\
echo -e "\n/////////////////// ajusting time and date //////////////////\n" && \
timedatectl set-timezone Asia/Shanghai && \
yum install ntpdate -y && \
ntpdate ntp1.aliyun.com && \
echo -e "\n///////////////////// the current date is //////////////////////\n"
date && \
echo -e "\n//////////////////////////Yum repo//////////////////////\n"
echo "Do you want to download local yum mirror of china?"
read -p "enter 'yes' or 'no': " yum_input
if [[ "$yum_input" = "yes" ]];
then
	version=`awk '{print $4}' /etc/redhat-release|awk -F . '{print $1}'`
	echo -e "◎Downloading mirror of centos$version\n"
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup &&\
	curl -o /etc/yum.repos.d/CentOS-Base.repo mirrors.aliyun.com/repo/Centos-$version.repo &&\
	curl -o /etc/yum.repos.d/epel.repo mirrors.aliyun.com/repo/epel-7.repo &&\
	yum clean all && yum makecache
elif [[ "$yum_input" = "no" ]];
then
	echo "Using source yum mirror"
else
    echo -e "\nNo valid text entered\n"
fi
yum install epel-release -y && \
echo -e "\n///////////////////// installing basic tools /////////////////////\n"
yum install net-tools vim -y && \
echo -e "\n///////////////////// checking selinux status /////////////////////\n"
getenforce &&\sleep 1s
echo -e "\n/////////////////// Configuring SSH ////////////////////\n"
sed -i "s/#TCPKeepAlive yes/TCPKeepAlive yes/g" /etc/ssh/sshd_config &&\
sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 60/g" /etc/ssh/sshd_config &&\
sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 30/g" /etc/ssh/sshd_config &&\
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config &&\
sed -i "s/#PermitRootLogin no/PermitRootLogin yes/g" /etc/ssh/sshd_config &&\
sed -i "s/PrintMotd no/PrintMotd yes/g" /etc/ssh/sshd_config &&\
cat /etc/ssh/sshd_config |grep TCP;sleep 1 &&\
systemctl restart sshd &&\
echo -e "\n/////////////////// Configuring Firewall ////////////////////\n"
firewall-cmd --zone=public --add-port=25/tcp --permanent &&\
firewall-cmd --zone=public --add-port=80/tcp --permanent &&\
firewall-cmd --zone=public --add-port=443/tcp --permanent &&\
firewall-cmd --zone=public --add-port=465/tcp --permanent &&\
firewall-cmd --reload &&\
echo -e "\n///////////////// the following ports are opened //////////////////\n"
firewall-cmd --zone=public --list-ports &&\
echo -e "\n//////////////////////////checking selinux//////////////////////\n"
if [[ 'getenforce'="Enforcing" ]];
then
    sed -i "s/SELINUX=enforcing/SELINUX=permissive/g" /etc/selinux/config &&\
    setenforce 0 &&\
    echo -e "\n///////////////////// selinux config has been modified ///////////////////\n"
    grep SELINUX /etc/selinux/config && getenforce
else
    echo -e "\n/////////////////////// nothing needs to modify ///////////////////////\n"
fi
echo -e "\n//////////////////////////LAMP or LNMP enviroment//////////////////////\n"
echo "Do you want to install LAMP or LNMP now?"
read -p "enter 'LAMP' or 'LNMP' or 'no': " user_input
if [[ "$user_input" = "LNMP" ]];
then
	echo "Start install LNMP"
	yum install nginx mariadb-server php php-fpm -y
elif [[ "$user_input" = "LAMP" ]];
then
	echo "Start install LAMP"
	yum install httpd mariadb-server php php-fpm -y
elif [[ "$user_input" = "no" ]];
then
	echo "quit installation..."
else
    echo -e "\nNo valid text entered\n"
fi
echo -e "\n//////////////////////////Ansible installation//////////////////////\n"
echo "Do you want to install Ansible now?"
read -p "enter 'yes' or 'no': " user_input
if [[ "$user_input" = "yes" ]];
then
	echo "Start install ansible"
	yum install ansible -y
elif [[ "$user_input" = "no" ]];
then
	echo "quit installation..."
else
    echo -e "\nNo valid text entered\n"
fi
echo -e "\n/////////////////////  checking system info ///////////////////////\n"
cat /etc/redhat-release && \
cat /proc/cpuinfo|grep cores;cat /proc/cpuinfo|grep MHz|sed -n 1p && \
cat /proc/meminfo|grep MemTotal;cat /proc/meminfo |grep MemFree
echo -e "\n+-------------finished-------------+\n"
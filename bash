#!/bin/bash

clear

#Case Variable
Stp=$1

#Date Variable
Today=`date +%d_%m_%Y`


header="\033[0;97m$s\t\t%-60s %-10s\n\e[0m"
psformat="\033[0;92m$s\t%-90s %-10s\n\e[0m"
flformat="\033[0;91m$s\t%-90s %-10s\n\e[0m"
dsformat="\033[0;93m$s\t%-90s %-10s\n\e[0m"


# OS Version Variable
OSVersion=`lsb_release -a | grep Description: | awk -F ":" '{print $2}' | awk -F "(" '{print $1}' |  sed -e 's/^[ \t]*//'`
# CPU Count Variable
CPUNo=`cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l`
# RAM Variable in GB
RAMGb=`free -m | grep "Mem:" | awk '{print $2}' | awk '{$1=$1/1024; print $1,"GB";}' | awk '{printf("%d\n",$1 + 0.9)}'`
# UPTime Variable
UPTm=`uptime | awk '{print $3 " " $4 " " $5}'`
# HostName Variable
HTName=`hostname -s`

# OSI Env Info
EnvInfo=`hostname -s | cut -c 4-7`


case "$EnvInfo" in
prda|prdb)
Environment=Producation
;;
nfta|nftb|ppt )
Environment=Test
;;
sit1|sit4|sit5|stg7 )
Environment=Development
;;
dev1|dev2|stg8 )
Environment=Engineering
;;

esac


BACKUPFOLDER="/var/logs/$EnvInfo/`hostname -s`/`date +%d_%m_%y`/Backup"

if [[ ! -d $LOGFOLDER ]]
then
    mkdir -p $BACKUPFOLDER
fi

LOGFOLDER="/var/logs/$EnvInfo/`hostname -s`/`date +%d_%m_%y`/Logs"

if [[ ! -d $LOGFOLDER ]]
then
    mkdir $LOGFOLDER
fi



# Current Time Zone
CTZoneMD=`md5sum /etc/localtime | awk '{print $1}'`

if [[ ! -z $( find /usr/share/zoneinfo -type f | xargs md5sum | grep -w $CTZoneMD | grep -w "Australia/Melbourne" ) ]]
   then
      CRTimeZone="Australia/Melbourne"
   else
      CRTimeZone=`find /usr/share/zoneinfo/posix  -type f | xargs md5sum | grep -w $CTZoneMD | tail -1 | awk '{print $2}' | rev | awk -F "/" '{print $1"-" $2}' | rev`
fi

# OS BIT Condition
OSBit=`uname -m`
case "$OSBit" in
   "i686") OSBit="32"
   ;;
   "x86_64") OSBit="64"
   ;;
esac


CPU_Output(){
echo -e "cpu output start\n"
echo -e "$CPUNo\n"
echo -e "cpu output end\n"
}

RAM_Output(){
echo -e "ram output start\n"
echo -e "$RAMGb\n"
echo -e "ram output end\n"
}

Kern_Output(){
echo -e "kernel output start\n"
uname -r
echo -e "\n"
echo -e "kernel output end\n"
}

iminfo_Output(){
echo -e "imageinfo output start\n"
imageinfo
echo -e "\n"
echo -e "imageinfo output end\n"
}


Df_Output(){
echo -e "df output start\n"
df -hP | sed 1d | awk '{print $6}' | tr -d ''
echo -e "\n"
echo -e "df output end\n"
}

Mount_Output(){
echo -e "mount output start\n"
mount
echo -e "\n"
echo -e "mount output end\n"
}


FsTab_Output(){
echo -e "fstab output start\n"
cat /etc/fstab | sed '/^\s*$/d'
echo -e "\n"
echo -e "fstab output end\n"
}


TimeZone_Output(){
echo -e "timezone output start\n"

find /usr/share/zoneinfo -type f | xargs md5sum | grep -w $CTZoneMD | grep -w "Australia/Melbourne"
echo -e "\n"
echo -e "timezone output end\n"
}



NTP_Output(){

echo -e "ntp output start\n"
ntpdc -c sysinfo | grep -w "system peer:" | awk '{print $3}'
ntpdc -c sysinfo | grep -w "reference ID:" | awk -F '[][]' '{print $2}'
echo -e "ntp output end\n"

}


Ldap_Output(){

echo -e "ldap output start\n"
cat /etc/ldap.conf
echo -e "ldap output end\n"

}

NssWitch_Output(){

echo -e "nsswitch output start\n"
cat /etc/nsswitch.conf | grep -w '^passwd:\|^group:\|^shadow:\|^sudoers:'
echo -e "nsswitch output end\n"

}

sysCTL_Output(){

echo -e "sysctl output start\n"
sysctl -p
echo -e "sysctl output end\n"

}

Ulimit_Output(){
echo -e "ulimit output start\n"
ulimit -a 2>/dev/null
echo -e "ulimit output end\n"
}


GateWay_Output(){
echo -e "gateway output start\n"
netstat -rn |awk '{if($1=="0.0.0.0") print $2}'
echo -e "gateway output end\n"
}

IPRoute_Output(){
echo -e "ip route output start\n"
ip route
echo -e "ip route output end\n"
}

Iptables_Output(){
echo -e "iptables output start\n"
iptables -L | sed '/^\s*$/d'
echo -e "\n"
echo -e "iptables output end\n"
}

OEM_Output(){
echo -e "oem output start\n"
 ps -e -o command | grep emagent | grep -v grep
echo -e "\n"
echo -e "oem output end\n"
}

RPMList_Output(){
echo -e "rpm list output start\n"
rpm -qa
echo -e "\n"
echo -e "rpm list output end\n"
}

VASD_Output(){

if [[ ! -z $(/etc/init.d/vasd status | grep running) ]]
then
   echo -e "vasd output start\n"
   echo "running"
   echo -e "\n"
   echo -e "vasd output end\n"
else
   echo -e "vasd output start\n"
   echo "stop"
   echo -e "\n"
   echo -e "vasd output end\n"
fi

}

OSWBB_Output(){

if [[ ! -z $(/etc/init.d/oswbb status | grep running) ]]
then
   echo -e "oswbb output start\n"
   echo "running"
   echo -e "\n"
   echo -e "oswbb output end\n"
else
   echo -e "oswbb output start\n"
   echo "stop"
   echo -e "\n"
   echo -e "oswbb output end\n"
fi

}


weblogic_Server_Output(){

if [[ ! -z $(ps -ef | grep oracle |grep weblogic.Server | grep -v grep) ]]
then
   echo -e "weblogic.Server output start\n"
   echo "running"
   echo -e "\n"
   echo -e "weblogic.Server output end\n"
else
   echo -e "weblogic.Server output start\n"
   echo "stop"
   echo -e "\n"
   echo -e "weblogic.Server output end\n"
fi

}


weblogic_AdminServer_Output(){

if [[ ! -z $(ps -ef | grep oracle | grep "Dweblogic.Name=" | grep  -i "Dweblogic.Name=AdminServer" | grep -v grep) ]]
then
   echo -e "weblogic.AdminServer output start\n"
   echo "running"
   echo -e "\n"
   echo -e "weblogic.AdminServer output end\n"
else
   echo -e "weblogic.AdminServer output start\n"
   echo "stop"
   echo -e "\n"
   echo -e "weblogic.AdminServer output end\n"
fi

}


opmn_agent_Output(){

if [[ ! -z $(ps -ef | grep "opmn " | grep -v grep ) ]]
then
   echo -e "opmn agent output start\n"
   echo "running"
   echo -e "\n"
   echo -e "opmn agent output end\n"
else
   echo -e "opmn agent output start\n"
   echo "stop"
   echo -e "\n"
   echo -e "opmn agent output end\n"
fi

}


menu_Output(){



tput cup 5 25
tput bold
tput setf 1
echo -e "*********************************************************************"

tput cup 6 25
tput bold
tput setf 1
echo -e "*"

tput cup 6 93
tput bold
tput setf 1
echo -e "*"

tput cup 7 25
tput bold
tput setf 1
echo -e "*"

tput cup 7 93
tput bold
tput setf 1
echo -e "*"

tput cup 8 25
tput bold
tput setf 1
echo -e "*"

tput cup 8 93
tput bold
tput setf 1
echo -e "*"

tput cup 9 25
tput bold
tput setf 1
echo -e "*********************************************************************"

}


header_host() {
echo -e "\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m"
printf "$header" "     $HOSTNAME" "             Dated : `date +%d-%b-%Y`"
echo -e "\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m"
echo -e "\033[0;97m OS Version: $OSVersion  \t\t\tCPU Count: $CPUNo\t  RAM : $RAMGb GB \e[0m"
echo -e "\033[0;97m Environment: $Environment    System Architecture: $OSBit BITs\tUPTIME: $UPTm\tTimezone: $CRTimeZone\e[0m"
echo -e "\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m"
}


while :
do

case "$Stp" in
pre|PRE )

LOGFILE="$LOGFOLDER/PREHealthCheck-`hostname -s`-`date +%d_%m_%y-%H_%M`.txt"
PRETEMPLOGFILE="$LOGFOLDER/TempPREHealthCheck-`hostname -s`-`date +%d_%m_%y-%H_%M`.txt"


PATTERN=($LOGFOLDER/TempPREHealthCheck-*.txt)
/bin/rm -rf $PATTERN    

if [[ ! -d $LOGFOLDER ]]
then
    mkdir $LOGFOLDER
fi

header_host | tee -a $LOGFILE
echo -e "\033[0;97m \t\t\t\t PRE Reboot System HealthCheck\e[0m" | tee -a $LOGFILE
echo -e "\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m\n" | tee -a $LOGFILE

/bin/cp -arf /etc/fstab /etc/ldap.conf /etc/nsswitch.conf /etc/ntp.conf /etc/security /etc/sudoers.d /etc/sysconfig /etc/sysctl.conf $BACKUPFOLDER

CPU_Output >> $PRETEMPLOGFILE    




RAM_Output >> $PRETEMPLOGFILE    
Kern_Output >> $PRETEMPLOGFILE    
iminfo_Output >> $PRETEMPLOGFILE    
Df_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t|\t  DF Command Out Put                |\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" | tee -a $LOGFILE
df -hP  | tee -a $LOGFILE
echo -e "\n" | tee -a $LOGFILE

FsTab_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  Fstab File Output                 |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
cat /etc/fstab  >> $LOGFILE    
echo -e "\n" >> $LOGFILE

Mount_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  Mount Command Output              |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
mount  >> $LOGFILE    
echo -e "\n" >> $LOGFILE


TimeZone_Output >> $PRETEMPLOGFILE    

NTP_Output >> $PRETEMPLOGFILE   

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  NTP.Conf File Output              |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
ntpdc -c sysinfo | grep -w "system peer:" | awk '{print $3}' >> $LOGFILE
ntpdc -c sysinfo | grep -w "reference ID:" | awk -F '[][]' '{print $2}' >> $LOGFILE
echo -e "\n" >> $LOGFILE

Ldap_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  LDAP.Conf File Output             |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
cat /etc/ldap.conf  >> $LOGFILE    
echo -e "\n" >> $LOGFILE

NssWitch_Output >> $PRETEMPLOGFILE

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  NSSWITCH.Conf File Output         |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
cat /etc/nsswitch.conf | grep -w '^passwd:\|^group:\|^shadow:\|^sudoers:' >> $LOGFILE
echo -e "\n" >> $LOGFILE


sysCTL_Output >> $PRETEMPLOGFILE  2>/dev/null  

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  SYSCTL.Conf File Output           |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
sysctl -p  >> $LOGFILE 2>/dev/null
echo -e "\n" >> $LOGFILE

Ulimit_Output >> $PRETEMPLOGFILE 2>/dev/null

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  ULIMIT Command Output             |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
ulimit -a  >> $LOGFILE    
echo -e "\n" >> $LOGFILE

GateWay_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  Default GateWay Output            |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
netstat -rn |awk '{if($1=="0.0.0.0") print $2}'  >> $LOGFILE    
echo -e "\n" >> $LOGFILE


IPRoute_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  IP Route Command Output           |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
ip route  >> $LOGFILE    
echo -e "\n" >> $LOGFILE

Iptables_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\t  IPTables Command Output           |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" >> $LOGFILE
iptables -L | sed '/^\s*$/d'  >> $LOGFILE    
echo -e "\n" >> $LOGFILE

OEM_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t|\t  OEM Agent Status Output           |\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" | tee -a $LOGFILE
ps -ef | grep -i agent_13.2.0.0.0 | egrep -v grep >/dev/null 2>&1
if [[ "$?" == "0" ]]; then
	runuser -l oraagent -c '/bin/sh /oracle/oem/agent13c/agent_13.2.0.0.0/bin/emctl status agent'  >> $LOGFILE 2>/dev/null
	runuser -l oraagent -c '/bin/sh /oracle/oem/agent13c/agent_13.2.0.0.0/bin/emctl status agent | grep "Agent is Running and Ready"' 2>/dev/null
else
	runuser -l oraagent -c '/bin/sh /oracle/oem/agent12c/core/12.1.0.4.0/bin/emctl status agent'  >> $LOGFILE 2>/dev/null
	runuser -l oraagent -c '/bin/sh /oracle/oem/agent12c/core/12.1.0.4.0/bin/emctl status agent | grep "Agent is Running and Ready"' 2>/dev/null
fi
echo -e "\n" >> $LOGFILE

OSWBB_Output >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t|\t  OSWBB Service Status Out Put      |\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" | tee -a $LOGFILE

/etc/init.d/oswbb status | tee -a $LOGFILE    

echo -e "\n" | tee -a $LOGFILE

RPMList_Output >> $PRETEMPLOGFILE    


case "$EnvInfo" in
stg8|nfta|nftb|ppte|prda|prdb )

VASD_Output  >> $PRETEMPLOGFILE    

echo -e "\033[0;97m\t\t---------------------------------------------\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t|\t  VASD Service Status Out Put       |\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t\t---------------------------------------------\e[0m\n" | tee -a $LOGFILE

/etc/init.d/vasd status | tee -a $LOGFILE    

echo -e "\n" | tee -a $LOGFILE

;;
esac


weblogic_Server_Output >> $PRETEMPLOGFILE    


if [[ ! -z $(ps -ef | grep oracle | grep weblogic.Server | grep -v grep) ]]

then
echo -e "\033[0;97m\t\t-------------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|\tWeblogic Server Service Status Out Put  |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t-------------------------------------------------\e[0m\n" >> $LOGFILE

ps -ef | grep oracle |grep weblogic.Server | grep -v grep >> $LOGFILE

echo -e "\n" >> $LOGFILE

fi



weblogic_AdminServer_Output >> $PRETEMPLOGFILE    

if [[ ! -z $(ps -ef | grep oracle | grep "Dweblogic.Name=" | grep  -i "Dweblogic.Name=AdminServer" | grep -v grep) ]]

then
echo -e "\033[0;97m\t\t-------------------------------------------------\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t|   Weblogic AdminServer Server Status Out Put  |\e[0m" >> $LOGFILE
echo -e "\033[0;97m\t\t-------------------------------------------------\e[0m\n" >> $LOGFILE

ps -ef | grep oracle | grep "Dweblogic.Name=" | grep  -i "Dweblogic.Name=AdminServer" | grep -v grep >> $LOGFILE

echo -e "\n" >> $LOGFILE

fi


ls /oracle/app/*/*/environments/*/bin >/dev/null 2>&1
if [[ $? = 0 ]]
then
    opmn_agent_Output >> $PRETEMPLOGFILE 2>/dev/null    

    echo -e "\033[0;97m\t\t-------------------------------------------------\e[0m" | tee -a $LOGFILE
    echo -e "\033[0;97m\t\t|\t     OPMN Agent Status Out Put          |\e[0m" | tee -a $LOGFILE
    echo -e "\033[0;97m\t\t-------------------------------------------------\e[0m\n" | tee -a $LOGFILE
    runuser -l oracle -c '/usr/bin/perl /oracle/app/sit5/secextoid/environments/sit5ext_oidinst_1/bin/opmnctl status -l' 2>/dev/null | tee -a $LOGFILE 
    echo -e "---------------------------------+--------------------+---------+----------+------------+----------+-----------+------" | tee -a $LOGFILE
    echo -e "\n" | tee -a $LOGFILE
fi

echo -e "\\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t Log File Path $LOGFILE \e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t Backup File Path $BACKUPFOLDER \e[0m" | tee -a $LOGFILE
echo -e "\\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m\e[0m" | tee -a $LOGFILE

exit;
;;


post|POST )

LOGFILE="$LOGFOLDER/POSTHealthCheck-`hostname -s`-`date +%d_%m_%y-%H_%M`.txt"
POSTTEMPLOGFILE="$LOGFOLDER/TempPOSTHealthCheck-`hostname -s`-`date +%d_%m_%y-%H_%M`.txt"
/bin/rm -rf $POSTTEMPLOGFILE    

PATTERN=($LOGFOLDER/TempPREHealthCheck-*.txt)

if [[ -f ${PATTERN[0]} ]]
then
    PREHC=`ls -t $LOGFOLDER | grep "^TempPREHealthCheck" | head -1`
    echo $PREHC
else
   echo "PRE HealthCheck File Not Exist" | tee -a $LOGFILE
LOGFlPth | tee -a $LOGFILE
   exit
fi

tput clear


tput cup 3 40
tput bold
tput rev
tput setf 2
echo "POST Reboot System HealthCheck"


tput sgr0

menu_Output

tput cup 7 26
tput bold
tput setf 7
#read -p "       Is That Capacity Enhancement Activity (Y/N) :  " PatchMaint

echo -e "\n\n\n"
tput sgr0

tput clear


header_host | tee -a $LOGFILE
echo -e "\033[0;97m \t\t\t\t POST Reboot System HealthCheck\e[0m" | tee -a $LOGFILE
echo -e "\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m\n" | tee -a $LOGFILE

echo -e "\033[0;97mKernel Version Update\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m---------------------\e[0m" | tee -a $LOGFILE

echo -e "\t\033[0;97mPre Reboot Kernel Version\t\t\t\t    Post Reboot Kernel Version\e[0m" | tee -a $LOGFILE
echo -e "\t\033[0;97m-------------------------\t\t\t\t    --------------------------\e[0m" | tee -a $LOGFILE

format="\t$s%-60s %-50s\n"
set -f
IFS='
'
set -- $( uname -r )
for i in `sed -n '/^kernel output start$/,/^kernel output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do
  printf "$format" "$i" "$1" | tee -a $LOGFILE
  shift
done

echo -e "\n" | tee -a $LOGFILE

echo -e "\033[0;97mImageInfo Version Update\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m------------------------\e[0m" | tee -a $LOGFILE

echo -e "\t\033[0;97mPre Reboot ImageInfo Version\t\t\t\t    Post Reboot ImageInfo Version\e[0m" | tee -a $LOGFILE
echo -e "\t\033[0;97m----------------------------\t\t\t\t    -----------------------------\e[0m" | tee -a $LOGFILE

set -f
IFS='
'
set -- $( imageinfo )
for i in `sed -n '/^imageinfo output start$/,/^imageinfo output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do
  printf "$format" "$i" "$1" | tee -a $LOGFILE
  shift
done

echo -e "\n" | tee -a $LOGFILE

count=1
IFS=$'\n'
for line in `rpm -qa`
do

if [[ -z $(sed -n '/^rpm list output start$/,/^rpm list output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep -w "^$line$") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "rpm list extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo $line >> $POSTTEMPLOGFILE
    extrarpmlarray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extrarpmlarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nrpm list extra entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extrarpmlarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then

    echo -e "\033[0;97mAfter Reboot Find Following Updated List of RPM's\e[0m" | tee -a $LOGFILE
    echo -e "\033[0;97m-------------------------------------------------\e[0m" | tee -a $LOGFILE

     sed -n '/^rpm list extra entrys start$/,/^rpm list extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        echo -e  "\t$line" | tee -a $LOGFILE
     done

echo -e "\n" | tee -a $LOGFILE

fi
echo -e "\n\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m" | tee -a $LOGFILE


ncount=1

count=1
IFS=$'\n'
for line in `df -hP | sed 1d | awk '{print $6}'| tr -d ''`
do

if [[ -z $(sed -n '/^df output start$/,/^df output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line$") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "df extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo $line  >> $POSTTEMPLOGFILE
    extradftoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${extradftoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\ndf extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^df output start$/,/^df output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( df -hP | sed 1d | awk '{print $6}' | tr -d '' | grep "^$line$") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "df missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo $line  >> $POSTTEMPLOGFILE
    misdftoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${misdftoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\ndf missing entrys end\n" >> $POSTTEMPLOGFILE
fi

if [[ `echo ${extradftoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${misdftoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Post DF OutPut HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Post DF OutPut HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extradftoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Mount Point in 'DF'" | tee -a $LOGFILE


   IFS=$'\n'
   for line in `sed -n '/^df extra entrys start$/,/^df extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d'`
   do
        dffexarray+=( "$line," )
   done
        DfExtMt=`echo ${dffexarray[@]} | sed '/^$/d'`
        printf "$dsformat" "  ($DfExtMt)" | tee -a $LOGFILE

  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${misdftoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Mount Point in 'DF'" | tee -a $LOGFILE

   IFS=$'\n'
   for line in `sed -n '/^df missing entrys start$/,/^df missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d'`
   do
        dffmisarray+=( "$line," )
   done
        DfMistMt=`echo ${dffmisarray[@]} | sed '/^$/d'`
        printf "$dsformat" "  ($DfMistMt)" | tee -a $LOGFILE

   fi
fi
ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


count=1
IFS=$'\n'
for line in `mount`
do

if [[ -z $(sed -n '/^mount output start$/,/^mount output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "mount extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extramntoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${extramntoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nmount extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^mount output start$/,/^mount output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( mount | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "mount missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    mismntoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${mismntoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nmount missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extramntoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${mismntoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Post Mount OutPut HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Post Mount OutPut HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extramntoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Mount Point in 'Mount'" | tee -a $LOGFILE

     sed -n '/^mount extra entrys start$/,/^mount extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${mismntoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Mount Point in 'Mount'" | tee -a $LOGFILE

     sed -n '/^mount missing entrys start$/,/^mount missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

count=1
IFS=$'\n'
for line in `cat /etc/fstab`
do

if [[ -z $(sed -n '/^fstab output start$/,/^fstab output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "fstab extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extrafstoparray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extrafstoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nfstab extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^fstab output start$/,/^fstab output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( cat /etc/fstab | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "fstab missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    misfstoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${misfstoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nfstab missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extrafstoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${misfstoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify FsTab File HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify FsTab File HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extrafstoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Entry in '/etc/fstab'" | tee -a $LOGFILE

     sed -n '/^fstab extra entrys start$/,/^fstab extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${misfstoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Entry in '/etc/fstab'" | tee -a $LOGFILE

     sed -n '/^fstab missing entrys start$/,/^fstab missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

#ncount=$((ncount+1))

#echo -e "\n" | tee -a $LOGFILE

#if [[ ! -z $( find /usr/share/zoneinfo -type f | xargs md5sum | grep -w $CTZoneMD | grep -w "Australia/Melbourne" ) ]]
#   then
#     printf "$psformat" "$ncount. Verify Time Zone HealthCheck"                        "[ PASSED ]" | tee -a $LOGFILE
#   else
#     printf "$flformat" "$ncount. Verify Time ZoneHealthCheck "                        "[ FAILED ]" | tee -a $LOGFILE
#     printf "$dsformat" "Error:- Current Time Zone is $CRTimeZone while expected time zone is "Australia/Melbourne"" | tee -a $LOGFILE
#fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE
if [[ ! -z $(ps -ef | grep ntp | grep -v grep) ]]
then

NTPCsyspeer=`ntpdc -c sysinfo | grep -w "system peer:" | awk '{print $3}'`
NTPCrefid=`ntpdc -c sysinfo | grep -w "reference ID:" | awk -F '[][]' '{print $2}'`

  if [[ ! -z $(sed -n '/^ntp output start$/,/^ntp output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$NTPCsyspeer$") ]] && [[ ! -z $(sed -n '/^ntp output start$/,/^ntp output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$NTPCrefid$") ]]
  then
      printf "$psformat" "$ncount. Verify NTP service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
  else
      printf "$flformat" "$ncount. Verify NTP service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
        if [[  -z $(sed -n '/^ntp output start$/,/^ntp output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$NTPCsyspeer$") ]]
         then
            PreNTPCsyspeer=`sed -n '/^ntp output start$/,/^ntp output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | head -1`
            printf "$dsformat" "Error:- Current NTP service system peer is $NTPCsyspeer while expected NTP service system peer is $PreNTPCsyspeer" | tee -a $LOGFILE
        fi

        if [[  -z $(sed -n '/^ntp output start$/,/^ntp output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$NTPCrefid$") ]]
         then
            PreNTPCrefid=`sed -n '/^ntp output start$/,/^ntp output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | head -1`
            printf "$dsformat" "Error:- Current NTP service reference ID is $NTPCrefid while expected NTP service reference ID is $PreNTPCrefid" | tee -a $LOGFILE

        fi
  fi
else
   printf "$flformat" "$ncount. Verify NTP service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
   printf "$dsformat" "Error:- Current NTP service nto running while expected NTP service should be running" | tee -a $LOGFILE
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


count=1
IFS=$'\n'
for line in `cat /etc/ldap.conf`
do

if [[ -z $(sed -n '/^ldap output start$/,/^ldap output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "ldap extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extraldaptoparray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extraldaptoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nldap extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^ldap output start$/,/^ldap output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( cat /etc/ldap.conf | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "ldap missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    misldaptoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${misldaptoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nldap missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extraldaptoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${misldaptoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Ldap File HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Ldap File HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extraldaptoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Entry in '/etc/ldap.conf'" | tee -a $LOGFILE

     sed -n '/^ldap extra entrys start$/,/^ldap extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${misldaptoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Entry in '/etc/ldap.conf'" | tee -a $LOGFILE

     sed -n '/^ldap missing entrys start$/,/^ldap missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


count=1
IFS=$'\n'
for line in `cat /etc/nsswitch.conf | grep -w '^passwd:\|^group:\|^shadow:\|^sudoers:'`
do

if [[ -z $(sed -n '/^nsswitch output start$/,/^nsswitch output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "nsswitch extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extranswttoparray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extranswttoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nnsswitch extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^nsswitch output start$/,/^nsswitch output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( cat /etc/nsswitch.conf | grep -w '^passwd:\|^group:\|^shadow:\|^sudoers:' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "nsswitch missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    misnswttoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${misnswttoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nnsswitch missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extranswttoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${misnswttoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify NsSwitch File HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify NsSwitch File HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extranswttoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Setting in '/etc/nsswitch.conf'" | tee -a $LOGFILE

     sed -n '/^nsswitch extra entrys start$/,/^nsswitch extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${misnswttoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Setting in '/etc/nsswitch.conf'" | tee -a $LOGFILE

     sed -n '/^nsswitch missing entrys start$/,/^nsswitch missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

count=1
IFS=$'\n'
for line in `sysctl -p`
do

if [[ -z $(sed -n '/^sysctl output start$/,/^sysctl output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "sysctl extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extransctltoparray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extransctltoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nsysctl extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^sysctl output start$/,/^sysctl output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( sysctl -p | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "sysct missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    missctltoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${missctltoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nsysctl missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extransctltoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${missctltoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify SysCtl Parameter HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify NsSwitch Parameter HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extransctltoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Parameter in 'sysctl -p'" | tee -a $LOGFILE

     sed -n '/^sysctl extra entrys start$/,/^sysctl extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${missctltoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Parameter in 'sysctl -p'" | tee -a $LOGFILE

     sed -n '/^sysctl missing entrys start$/,/^sysctl missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


count=1
IFS=$'\n'
for line in `ulimit -a`
do

if [[ -z $(sed -n '/^ulimit output start$/,/^ulimit output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "ulimit extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extraulmtoparray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extraulmtoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nulimit extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^ulimit output start$/,/^ulimit output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( ulimit -a | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "ulimit missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    missulmtoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${missulmtoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nulimit missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extraulmtoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${missulmtoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Ulimit Parameter HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Ulimit Parameter HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extraulmtoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Parameter in 'ulimit -a'" | tee -a $LOGFILE

     sed -n '/^ulimit extra entrys start$/,/^ulimit extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${missulmtoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Parameter in 'ulimit -a'" | tee -a $LOGFILE

     sed -n '/^ulimit missing entrys start$/,/^ulimit missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


PreDfGateWay=`sed -n '/^gateway output start$/,/^gateway output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
DfGateWay=`netstat -rn |awk '{if($1=="0.0.0.0") print $2}'`

    if [[ $DfGateWay = $PreDfGateWay ]]
    then
       printf "$psformat" "$ncount. Verify Post Default GateWay HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
    else
       printf "$flformat" "$ncount. Verify Post Default GateWay HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE

       printf "$dsformat" "Error: Before Reboot Default GateWay IPAddress $PreDfGateWay And After Reboot Default GateWay IPAddress is $DfGateWay" | tee -a $LOGFILE
    fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


count=1
IFS=$'\n'
for line in `ip route`
do

if [[ -z $(sed -n '/^ip route output start$/,/^ip route output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "ip route extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo ":- $line" >> $POSTTEMPLOGFILE
    extraiprutarray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extraiprutarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nip routet extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^ip route output start$/,/^ip route output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( ip route | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "ip route missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    missiprutoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${missiprutoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nip route missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extraiprutarray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${missiprutoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Route Parameter HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Route Parameter HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extraiprutarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Parameter in 'ip route'" | tee -a $LOGFILE

     sed -n '/^ip route extra entrys start$/,/^ip routet extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${missiprutoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Parameter in 'ip route'" | tee -a $LOGFILE

     sed -n '/^ip route missing entrys start$/,/^ip route missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE



count=1
IFS=$'\n'
for line in `iptables -L | sed '/^\s*$/d' | tr -d ''`
do


if [[ -z $(sed -n '/^iptables output start$/,/^iptables output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "iptables extra entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    extraibtbaarray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extraibtbaarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\niptables extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^iptables output start$/,/^iptables output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( iptables -L | sed '/^\s*$/d' | tr -d '' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "iptables missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo ":- $line" >> $POSTTEMPLOGFILE
    missibtboparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${missibtboparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\niptables missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extraibtbaarray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${missibtboparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Route Iptables Rules HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Route Iptables Rules HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extraibtbaarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Rules in 'iptables -L'" | tee -a $LOGFILE

     sed -n '/^iptables extra entrys start$/,/^iptables extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | tr -d '' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${missibtboparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Rules in 'iptables -L'" | tee -a $LOGFILE

     sed -n '/^iptables missing entrys start$/,/^iptables missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | tr -d '' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE


count=1
IFS=$'\n'
for line in `ps -e -o command | grep emagent | grep -v grep`
do

if [[ -z $(sed -n '/^oem output start$/,/^oem output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d' | grep "^$line") ]]
then
    if [[ $count = 1 ]]
    then
      echo -e "oem extra entrys start\n" >> $POSTTEMPLOGFILE
    fi

    echo $line >> $POSTTEMPLOGFILE
    extraoemarray+=("$line")
    count=$((count+1))

fi
done

if [[ `echo ${extraoemarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\noem extra entrys end\n" >> $POSTTEMPLOGFILE
fi

count=1
IFS=$'\n'
for line in `sed -n '/^oem output start$/,/^oem output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
do

if [[ -z $( ps -e -o command | grep emagent | grep -v grep | grep "^$line") ]]
then
    if [[ $count = 1 ]]
      then
      echo -e "oem missing entrys start\n" >> $POSTTEMPLOGFILE
    fi
    echo $line  >> $POSTTEMPLOGFILE
    missoemoparray+=("$line")
    count=$((count+1))

fi
done


if [[ `echo ${missoemoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\noem missing entrys end\n" >> $POSTTEMPLOGFILE
fi


if [[ `echo ${extraoemarray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${missoemoparray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify OEM Service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify OEM Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extraoemarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following OEM Process not Correct in 'ps -ef'" | tee -a $LOGFILE

     sed -n '/^oem extra entrys start$/,/^oem extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  ($line)" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${missoemoparray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following OEM Process not Correct in 'ps -ef'" | tee -a $LOGFILE

     sed -n '/^oem missing entrys start$/,/^oem missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  ($line)" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

case "$EnvInfo" in
stg8|nfta|nftb|ppte|prda|prdb )

VasdPreStatus=`sed -n '/^vasd output start$/,/^vasd output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`


if [[ ! -z $(/etc/init.d/vasd status | grep "$VasdPreStatus") ]]
then
   printf "$psformat" "$ncount. Verify VASD Service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify VASD Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
   if [[ ! -z $(/etc/init.d/vasd status | grep running) ]]
   then
      VasdPostStatus="running"
   else
     VasdPostStatus="stop"
   fi
   printf "$dsformat" "Error:- Current vasd service status $VasdPostStatus while expected vasd service status $VasdPreStatus" | tee -a $LOGFILE

fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

;;
esac

SudoersPostFlLists=`ls /etc/sudoers.d`
SudoersPreFlLists=`ls $BACKUPFOLDER/sudoers.d`

unset IFS
count=1
for SudoersPostFlList in `echo $SudoersPostFlLists`
do

    IFS=$'\n'
    for lines in `cat /etc/sudoers.d/$SudoersPostFlList | sed '/^\s*$/d'`
    do
        if [[ -f $BACKUPFOLDER/sudoers.d/$SudoersPostFlList ]]

        then
       line=`echo $lines | sed 's/[[:space:]]//g' | tr -d ''`

          if [[ -z $( cat $BACKUPFOLDER/sudoers.d/$SudoersPostFlList | sed '/^\s*$/d'| sed 's/[[:space:]]//g' | tr -d '' | grep -F -w "$line") ]] && [[ -z $( cat $BACKUPFOLDER/sudoers.d/$SudoersPostFlList | sed '/^\s*$/d'| sed 's/[[:space:]]//g' | tr -d '' | grep -w "^$line") ]]
           then
               if [[ $count = 1 ]]
                then
                  echo -e "sudoers extra entrys start\n" >> $POSTTEMPLOGFILE
               fi
           echo -e "$SudoersPostFlList" >> $POSTTEMPLOGFILE
           echo -e "------------------" >> $POSTTEMPLOGFILE
           echo -e ":- $lines\n" >> $POSTTEMPLOGFILE
           extrasudoerarray+=("$line")
           count=$((count+1))
           fi
        else
            if [[ $count = 1 ]]
             then
               echo -e "sudoers extra entrys start\n" >> $POSTTEMPLOGFILE
            fi
        echo -e ":- $SudoersPostFlList File Not Exist. Check in /etc/sudoers.d " >> $POSTTEMPLOGFILE
        count=$((count+1))
        fi

   done

done

if [[ `echo ${extrasudoerarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nsudoers extra entrys end\n" >> $POSTTEMPLOGFILE
fi


unset IFS

count=1
for SudoersPreFlList in `echo $SudoersPreFlLists`
do


   IFS=$'\n'
   for lines in `cat $BACKUPFOLDER/sudoers.d/$SudoersPreFlList | sed '/^\s*$/d'`
   do
        if [[ -f /etc/sudoers.d/$SudoersPreFlList ]]
        then
        line=`echo $lines | sed 's/[[:space:]]//g' | tr -d ''`
           if [[ -z $( cat /etc/sudoers.d/$SudoersPreFlList | sed '/^\s*$/d'| sed 's/[[:space:]]//g'  | grep -F -w "$line") ]] && [[ -z $( cat /etc/sudoers.d/$SudoersPreFlList | sed '/^\s*$/d'| sed 's/[[:space:]]//g'  | grep -w "^$line") ]]
           then
               if [[ $count = 1 ]]
                then
                  echo -e "sudoers missing entrys start\n" >> $POSTTEMPLOGFILE
               fi
            echo -e "$SudoersPreFlList" >> $POSTTEMPLOGFILE
            echo -e "-----------------" >> $POSTTEMPLOGFILE
            echo -e ":- $lines\n" >> $POSTTEMPLOGFILE
            misssudoerarray+=("$line")
           count=$((count+1))
           fi

        else
        if [[ $count = 1 ]]
             then
               echo -e "sudoers missing entrys start\n" >> $POSTTEMPLOGFILE
            fi

        echo -e ":- $SudoersPreFlList File Not Exist, Check in /etc/sudoers.d" >> $POSTTEMPLOGFILE
        count=$((count+1))
        fi
    done
done

if [[ `echo ${misssudoerarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
then
    echo -e "\nsudoers missing entrys end\n" >> $POSTTEMPLOGFILE
fi

if [[ `echo ${extrasudoerarray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]] && [[ `echo ${misssudoerarray[@]} | sed '/^\s*$/d' | wc -c` = 0 ]]
then
   printf "$psformat" "$ncount. Verify Sudoer File's HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Sudoer File's HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE


  if [[ `echo ${extrasudoerarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
  then

     printf "$dsformat" "Error: After Reboot Find Following Extra Information, Check in '/etc/sudoers.d'" | tee -a $LOGFILE

     sed -n '/^sudoers extra entrys start$/,/^sudoers extra entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
  fi
echo -e "\n" | tee -a $LOGFILE

  if [[ `echo ${misssudoerarray[@]} | sed '/^\s*$/d' | wc -c` != 0 ]]
   then

     printf "$dsformat" "Error: After Reboot Find Following Missing Information, Check in '/etc/sudoers.d'" | tee -a $LOGFILE

     sed -n '/^sudoers missing entrys start$/,/^sudoers missing entrys end$/p' "$POSTTEMPLOGFILE" | sed '/^\s*$/d' | sed 1d | sed '$d' | while read line
     do
        printf "$dsformat" "  $line" | tee -a $LOGFILE
     done
   fi
fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

if [[ 1 -ge `ps -ef | grep chef  | grep -v grep | wc -l` ]]
then
    #if [[ ! -z $(ps -ef | grep srv-ecc-collect  | grep chef | grep -v grep) ]]
    #then
  printf "$psformat" "$ncount. Verify Chef Service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
    #else
    #  printf "$flformat" "$ncount. Verify Chef Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE

     #if [[ ! -z $(ps -ef | grep root | grep chef | grep -v grep) ]]
     #  then
     #      printf "$dsformat" "Error:- Current chef service owner is 'root' while expected chef service ower is 'srv-ecc-collect'" | tee -a $LOGFILE
     #  else

      #     printf "$dsformat" "Error:- chef service Not Runnig or service owner not correct while expected chef service ower is 'srv-ecc-collect'" | tee -a $LOGFILE
     #fi

   #fi
else
  printf "$flformat" "$ncount. Verify Chef Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
   #printf "$dsformat" "Error:- Multipal Chef agnet Running while expected chef run with 'srv-ecc-collect' ower " | tee -a $LOGFILE
fi


ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

OswbbPreStatus=`sed -n '/^oswbb output start$/,/^oswbb output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`


if [[ ! -z $(/etc/init.d/oswbb status | grep "$OswbbPreStatus") ]]
then
   printf "$psformat" "$ncount. Verify OSWBB Service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify OSWBB Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
   if [[ ! -z $(/etc/init.d/oswbb status | grep running) ]]
   then
      OswbbPostStatus="running"
   else
     OswbbPostStatus="stop"
   fi
   printf "$dsformat" "Error:- Current oswbb service status $OswbbPostStatus while expected oswbb service status $OswbbPreStatus" | tee -a $LOGFILE

fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

WlSerPreStatus=`sed -n '/^weblogic.Server output start$/,/^weblogic.Server output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`


if [[ ! -z $(ps -ef | grep oracle | grep weblogic.Server | grep -v grep) ]]
then
   WlSerPostStatus="running"
else
   WlSerPostStatus="stop"
fi

if  [[ $WlSerPostStatus = $WlSerPreStatus ]]
then
   printf "$psformat" "$ncount. Verify Weblogic Server Service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Weblogic Server Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
   printf "$dsformat" "Error:- Current Weblogic Server service status $WlSerPostStatus while expected Weblogic Server service status $WlSerPreStatus" | tee -a $LOGFILE

fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

WlAdminPreStatus=`sed -n '/^weblogic.AdminServer output start$/,/^weblogic.AdminServer output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`


if [[ ! -z $(ps -ef | grep oracle | grep "Dweblogic.Name=" | grep  -i "Dweblogic.Name=AdminServer" | grep -v grep) ]]
then
   WlAdminPostStatus="running"
else
   WlAdminPostStatus="stop"
fi

if  [[ $WlAdminPostStatus = $WlAdminPreStatus ]]
then
   printf "$psformat" "$ncount. Verify Weblogic AdminServer Service HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify Weblogic AdminServer Service HealthCheck "                "[ FAILED ]" | tee -a $LOGFILE
   printf "$dsformat" "Error:- Current Weblogic AdminServer service status $WlAdminPostStatus while expected Weblogic AdminServer service status $WlAdminPreStatus" | tee -a $LOGFILE

fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

ls /oracle/app/*/*/environments/*/bin    
if [[ $? = 0 ]]
then
    if [[ ! -z $(ps -ef | grep "opmn " | grep -v grep ) ]]
    then
       opmnPostStatus="running"
   else
       opmnPostStatus="stop"
   fi
opmnPreStatus=`sed -n '/^opmn agent output start$/,/^opmn agent output end$/p' "$LOGFOLDER/$PREHC" | sed '/^\s*$/d' | sed 1d | sed '$d'`
if  [[ $opmnPostStatus = $opmnPreStatus ]]
then
   printf "$psformat" "$ncount. Verify OPMN Agent Status HealthCheck "                "[ PASSED ]" | tee -a $LOGFILE
else
   printf "$flformat" "$ncount. Verify OPMN Agent Status HealthCheck"                "[ FAILED ]" | tee -a $LOGFILE
   printf "$dsformat" "Error:- Current OPMN Agent Status $opmnPostStatus while expected OPMN Agent Status $opmnPreStatus" | tee -a $LOGFILE

fi

ncount=$((ncount+1))

echo -e "\n" | tee -a $LOGFILE

fi

echo -e "\\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m\e[0m" | tee -a $LOGFILE
echo -e "\033[0;97m\t Log File Path $LOGFILE \e[0m" | tee -a $LOGFILE
echo -e "\\e[1;34;40m-----------------------------------------------------------------------------------------------------------------------\e[0m\e[0m" | tee -a $LOGFILE


/bin/rm -rf $POSTTEMPLOGFILE
#rm -rf $PATTERN
exit;
;;
*)
  tput clear
  menu_Output
  tput cup 7 26
  tput bold
  tput setf 7
  read -p "       Choose Correct Opestion (PRE, POST): " Stp ;
  tput clear

  continue;;
esac
done


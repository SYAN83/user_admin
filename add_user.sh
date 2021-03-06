#!/bin/bash
usage()
{
    echo "Usage: $0 -u <username> -g <group> [-e <days>] [-s]"
    exit 1
}
if [ "$#" -lt 4 ]
then
    usage
fi

# get username / group
while getopts u:g:e:s option
do
    case "${option}" in
    u) USER=${OPTARG};;
    g) GROUP=${OPTARG};;
    e) EXPIRE=${OPTARG};;
    s) SUDO=true;;
    esac
done

if [ "$USER" = "" -o "$GROUP" = "" ] || [[ ! $EXPIRE =~ ^[0-9]*$ ]]
then
    usage
fi

# generate random password
PSWD="$(openssl rand -base64 8 | tr '[:punct:]' $((RANDOM % 10)) | tr 1IloO0 2iL789)"
PSWDcrypt="$(openssl passwd -crypt $PSWD)"

# create log file
LOGFILE="users.log"
if [ ! -e $LOGFILE ]
then
    touch $LOGFILE
    chmod 600 $LOGFILE
fi

# create credentials file
LOGINS="credentials.yml"
if [ ! -e $LOGINS ]
then
    touch $LOGINS
    chmod 600 $LOGINS
fi

# create Linux user
if [ "$EXPIRE" = "" ]
then
    echo "Creating Linux user $USER"
    ERRMSG=`sudo useradd -m -p $PSWDcrypt -g $GROUP $USER 2>&1`
else
    EXPIRE_DATE=$(date +"%F" -d "+$EXPIRE days")
    echo "Creating Linux user $USER (EXPIRE_DATE: $EXPIRE_DATE)"
    ERRMSG=`sudo useradd -m -p $PSWDcrypt -g $GROUP -e $EXPIRE_DATE $USER 2>&1`
fi

if [ $? -ne 0 ]
then
    log="Failed to create user $USER ($ERRMSG)"
    echo "$log"
else
    log="Created user $USER"
    echo "$USER: $PSWD" >> $LOGINS
    echo "$log"
fi
echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 

# add user to admin
if [ $SUDO ]
then
    ERRMSG=`sudo usermod -aG admin $USER 2>&1`
    if [ $? -ne 0 ]
    then
        log="Failed to add user $USER to the admin group ($ERRMSG)"
        echo "$log"
    else
        log="Added user $USER to the admin group"
        echo "$log"
    fi
    echo -e "[$(date +"%F %T")] $log" >> $LOGFILE
fi

# create HDFS directory
echo "Creating HDFS directory for user $USER"
ERRMSG=`hadoop fs -mkdir /user/$USER 2>&1`

if [ $? -ne 0 ]
then
    log="Failed to create HDFS $USER ($ERRMSG)"
    echo "$log"
else
    log="Created HDFS $USER"
    echo "$log"
fi

# change HDFS permission
echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 
ERRMSG=`hadoop fs -chown -R $USER:$GROUP /user/$USER 2>&1`

if [ $? -ne 0 ] 
then
    log="Failed to change HDFS permission $USER ($ERRMSG)"
    echo "$log"
    echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 
fi


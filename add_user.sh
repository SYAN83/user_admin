#!/bin/bash
usage()
{
    echo "USAGE: $0 <username>"
    exit 1
}
if [ "$#" -ne 1 ]
then
    usage
fi

# create log file
LOGFILE="users.log"
if [ ! -e $LOGFILE ]
then
    touch $LOGFILE
    chmod 600 $LOGFILE
fi

# create credentials file for logins
LOGINS="credentials.yml"
if [ ! -e $LOGINS ]
then
    touch $LOGINS
    chmod 600 $LOGINS
fi

# create username and password
USER="$1"
PSWD="$(openssl rand -base64 8 | tr '[:punct:]' $((RANDOM % 10)) | tr 1IloO0 2iL789)"
PSWDcrypt="$(openssl passwd -crypt $PSWD)"

# create Linux user
echo "Creating Linux user $USER"
ERRMSG=`sudo useradd -m -p $PSWDcrypt $USER 2>&1`
if [ $? -ne 0 ]
then
    log="Failed to create user $USER ($ERRMSG)"
    echo "Failed to create user $USER."
else
    log="Created user $USER"
    echo "$USER: $PSWD" >> $LOGINS
    echo "Linux user $USER has been sucessfully created."
fi
echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 

# create HDFS directory
echo "Creating HDFS directory for user $USER"
ERRMSG=`hadoop fs -mkdir /user/$USER 2>&1`
if [ $? -ne 0 ]
then
    log="Failed to create HDFS $USER"
    echo "Failed to create HDFS directory for $USER."
else
    log="Created HDFS $USER"
    echo "HDFS dir for $USER has been sucessfully created."
fi
echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 
ERRMSG=`hadoop fs -chown -R $USER:$USER /user/$USER 2>&1`
if [ $? -ne 0 ] 
then
    log="Failed to change HDFS permission $USER"
    echo "Failed to change HDFS permission for $USER."
    echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 
fi

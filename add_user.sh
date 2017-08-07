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
# create log file if not existed
LOGFILE=users.log
touch $LOGFILE
chmod 600 $LOGFILE
LOGINS=credentials.yaml
touch $LOGFILE
chmod 600 $LOGFILE
# create username and password
USER=$1
PSWD=$(openssl rand -base64 8 | tr '[:punct:]' $((RANDOM % 10)) | tr 1IloO0 2iL789)
PSWDcrypt=$(openssl passwd -crypt $PSWD)
# create Linux user
echo "Creating user $USER..."
sudo useradd -m -p $PSWDcrypt $USER
if [ $? -ne 0 ]; then
	log="[$(date)] FAILED TO CREATE USER $USER"
	echo "Failed to create user $USER."
else
	log="[$(date)] CREATED USER $USER"
	echo "$USER: $PSWD" >> $LOGINS
	echo "User $USER has been sucessfully created."
fi
# create HDFS directory
hadoop fs -mkdir /user/$USER
if [ $? -ne 0 ]; then
        log="$log\n[$(date)] FAILED TO CREATE HDFS $USER"
        echo "Failed to create HDFS directory for $USER."
else
        hadoop fs -chown -R $USER:$USER /user/$USER
	if [ $? -ne 0 ]; then
		log="$log\n[$(date)] FAILED TO CHANGE HDFS PERMISSION $USER"
		echo "Failed to change HDFS permission for $USER."
	else
		log="$log\n[$(date)] CREATED HDFS $USER"
		echo "HDFS dir for $USER has been sucessfully created."
	fi
fi
echo -e $log >> $LOGFILE


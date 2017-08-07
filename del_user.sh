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

LOGFILE=users.log
USER=$1
TIME=$(date)

echo "Deleting user $USER..."
# delete HDFS directory
hadoop fs -rm -r /user/$USER
if [ $? -ne 0 ]; then
        log="[$TIME] FAILED TO DELETE HDFS $USER"
        echo "Failed to delete HDFS dir for $USER."
else
        log="[$TIME] DELETED HDFS $USER"
        echo "HDFS dir for $USER has been sucessfully deleted."
fi
# delete Linux user
sudo userdel -r $USER
if [ $? -ne 0 ]; then
	log="$log\n[$TIME] FAILED TO DELETE USER $USER"
	echo "Failed to delete user $USER."
else
	log="$log\n[$TIME] DELETED USER $USER"
	echo "User $USER has been sucessfully deleted."
fi
echo -e $log >> $LOGFILE 


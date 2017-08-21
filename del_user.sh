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

# user to delete
USER=$1

# delete HDFS directory
echo "Deleting HDFS for user $USER"
ERRMSG=`hadoop fs -rm -r /user/$USER 2>&1`
if [ $? -ne 0 ]
then
    log="Failed to delete HDFS $USER ($ERRMSG)"
    echo "Failed to delete HDFS dir for $USER."
else
    log="Deleted HDFS $USER"
    echo "HDFS dir for $USER has been sucessfully deleted."
fi
echo -e "[$(date +"%F %T")] $log" >> $LOGFILE

# delete Linux user
echo "Deleting Linux user $USER"
ERRMSG=`sudo userdel -r $USER 2>&1`
if [ $? -ne 0 ]
then
    log="Failed to delete user $USER ($ERRMSG)"
    echo "Failed to delete user $USER."
else
    log="Deleted user $USER"
    echo "User $USER has been sucessfully deleted."
fi
echo -e "[$(date +"%F %T")] $log" >> $LOGFILE 

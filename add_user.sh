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
touch $LOGFILE
chmod 600 $LOGFILE

USER=$1
TIME=$(date)
PSWD=$(openssl rand -base64 8 | tr '[:punct:]' $((RANDOM % 10)) | tr 1IloO0 2iL789)
PSWDcrypt=$(openssl passwd -crypt $PSWD)

echo "Creating user $USER..."
sudo useradd -m -p $PSWDcrypt $USER
if [ $? -ne 0 ]; then
	log="[$TIME] FAILED TO CREATE USER $USER"
	echo "Failed to create user $USER."
else
	log="[$TIME] CREATED USER $USER $PSWD"
	echo "User $USER has been sucessfully created."
fi

cat >> $LOGFILE <<EOF
$log
EOF



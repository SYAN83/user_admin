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

USER=$1
TIME=$(date)

echo "Deleting user $USER..."
sudo userdel -r $USER
if [ $? -ne 0 ]; then
	log="[$TIME] FAILED TO DELETE USER $USER"
	echo "Failed to delete user $USER."
else
	log="[$TIME] DELETED USER $USER."
	echo "User $USER has been sucessfully deleted."
fi

cat >> users.log <<EOF
$log
EOF



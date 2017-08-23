#!/usr/bin/python3
import subprocess

for i in range(22):
    # subprocess.call('./add_user.sh -u tempuser_{} -g student'.format(i), shell=True)
    subprocess.call('./del_user.sh tempuser_{}'.format(i), shell=True)

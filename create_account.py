#!/usr/bin/python3
import subprocess

for i in range(20):
    subprocess.call('./add_user.sh -u tempuser_{} -g student'.format(i), shell=True)

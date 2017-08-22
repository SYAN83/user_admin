#!/usr/bin/python3
import subprocess

for i in range(5):
    subprocess.call('./add_user.sh temp_{}'.format(i), shell=True)

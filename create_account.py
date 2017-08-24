#!/usr/bin/python3
import subprocess

with open('students.txt') as f:
    for line in f:
        student = line.strip().split(':',1)[0]
        subprocess.call('./add_user.sh -u {} -g student -e 30'.format(student), shell=True)
    print('done')

# for i in range(22):
    # subprocess.call('./add_user.sh -u tempuser_{} -g student'.format(i), shell=True)
    # subprocess.call('./del_user.sh tempuser_{}'.format(i), shell=True)

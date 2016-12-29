#!/usr/bin/env python

import os
import subprocess
import sys
import time

DELAY_BETWEEN_TESTS = 5  # delay in seconds
RETRIES = 10

# put server ip in here
site = "rpi0"

#logging into log_mount_nfs in /tmp
file = "/tmp/log_mount_nfs"
f = open(file,'w')
def log(str):
  f.write(str+'\n')

# issue Linux ping command to determine nas connection status
def ping():
  cmd = "/bin/ping -c 1 " + site
  try:
    output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, shell=True)
  except subprocess.CalledProcessError, e:
    log("ping failed")
    return 0
  else:
    log("ping ok")
    return 1

# main loop: ping sites, wait, repeat
count = RETRIES
while count >0:
  success = ping()
  if success == 1:
   log("run script")
   os.system("mount -t nfs rpi0:/home/pi/cloud /home/pi/cloud")
   log("finished")
   os.system("df -h")
   f.close()
   sys.exit()

  count = count - 1
  time.sleep(DELAY_BETWEEN_TESTS)

log("time up. mount failed")
f.close()
sys.exit(1)

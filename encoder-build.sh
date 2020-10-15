#!/bin/bash
if [ "$#" -ne 2 ]
  then
    echo "Usage ./encoder-build.sh <Name_of_VM> <Entrypoint_ID>"
    exit
fi

echo 
echo '**********************************************************************************'
echo Building encoder: $1
echo '**********************************************************************************'
echo

# Make SSH key for VM, store locally (SSH key never leaves local machine)
ssh-keygen -m PEM -t rsa -b 4096 -N '' -C '' -f $1

# Load key into variable, stripping off newline
ssh_key=$(cat $1.pub | tr -d '\n')

echo 
# Run newman to build instance, overriding the MachineKey and sshKey variables in the environment file, pace commands to avoid 429s
newman run vm-create.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
--env-var "sshKey=$ssh_key"  --delay-request 1000 --bail --reporter-cli-no-summary --reporter-cli-no-banner

# If OK, wait for instance to become available
if [ $? -ne 0 ]
then
   echo '--> Failed to build VM, already one with same name?'
   echo 
   exit 1
fi

# Try 10 times... waiting 10s per loop
echo 
echo Waiting 60s for VM to start up
count=0
while [ $count -lt 60 ] 
do
    sleep 1
    count=$[count + 1]
    echo -n .
done

echo
echo 
echo Checking for VM status...
count=0
while [ $count -lt 10 ] 
do
   echo 	
   newman run vm-checkrunning.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
   --reporter-cli-no-summary --reporter-cli-no-banner --reporter-cli-no-failures
   if [ $? -eq 0 ] 
   then
       break
   fi
   count=$[count + 1]
   echo Waiting for 10s before trying...
   sleep 10
done 

if [ $count -eq 10 ]
then
   echo '--> Timeout waiting for VM to startup'
   echo 
   exit 1
fi

# Issue run command to start installation
echo 
newman run vm-command.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
--env-var "runCommand=git clone https://github.com/peterchave/install-encoder.git && cd install-encoder && chmod +x *.sh && ./install.sh && ./config.sh $2" \
--reporter-cli-no-summary --reporter-cli-no-banner

# Fetch public IP
echo 
newman run vm-getpublicip.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
--export-environment exported.json  --reporter-cli-no-summary --reporter-cli-no-banner

ipaddress=$(cat exported.json | grep -B1 "publicIPaddress" | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
rm exported.json

# Return entrypoint to encoder for RTMP feed
echo 
echo '**********************************************************************************'
echo 'Encoder built on Azure - Name: '$1'-vm'
echo
echo 'Install will take approximately 5 minutes to complete'
echo
echo 'SSH access:'
echo 'ssh -i '$1' encadmin@'$ipaddress
echo 
echo 'Please use the following RTMP ingest:'
echo 'rtmp://'$ipaddress':1935/input'
echo 
echo 'LL-DASH manifest for playback:'
echo '<HOSTNAME>/cmaf/live-ull/'$2'/event/out.mpd'
echo '**********************************************************************************'
echo 
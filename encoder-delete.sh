#!/bin/bash
if [ -z "$1" ]
  then
    echo "Usage ./encoder-delete.sh <name_of_VM>"
    exit
fi
echo 
echo '**********************************************************************************'
echo Removing encoder: $1
echo '**********************************************************************************'
echo 
newman run vm-delete.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
--reporter-cli-no-summary --reporter-cli-no-banner

# If OK, wait for instance to become available - i.e. VM existed and is being shutdown
if [ $? -ne 0 ] 
then
   echo '--> VM not found, assume it was already deleted, proceeding to try and remove related resources'
fi

# Try 10 times... waiting 10s per loop
count=0
while [ $count -lt 10 ] 
do
   echo 
   newman run vm-checkdeleted.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
   --reporter-cli-no-summary --reporter-cli-no-banner --reporter-cli-no-failures
   if [ $? -eq 0 ] 
   then
       break
   fi
   count=$[count + 1]
   echo 
   echo Waiting for 10s before trying...
   sleep 10
done 

if [ $count -eq 10 ]
then
   echo '--> Timeout waiting for VM to shutdown, wait for 60s and retry command' 
   exit 1
fi

# Issue run command to start installation
newman run vm-cleanup.json  -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
--reporter-cli-no-summary --reporter-cli-no-banner

echo
echo '**********************************************************************************'
echo Removed encoder: $1
echo '**********************************************************************************'
echo 
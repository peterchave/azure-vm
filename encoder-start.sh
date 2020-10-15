#!/bin/bash
if [ -z "$1" ]
  then
    echo "Usage ./encoder-start.sh <name_of_VM>"
    exit
fi
echo 
echo '**********************************************************************************'
echo 'Start encoder: '$1
echo '**********************************************************************************'
echo 
newman run vm-command.json -e azure-credentials.json -g azure-globals.json --env-var "newMachineKey=$1" \
--env-var "runCommand=pm2 restart all" --reporter-cli-no-summary --reporter-cli-no-banner
echo
echo '**********************************************************************************'
echo 'Started encoder: '$1
echo '**********************************************************************************'
echo 
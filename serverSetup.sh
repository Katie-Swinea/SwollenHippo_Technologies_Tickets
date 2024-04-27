#! /bin/bash

#Description: A file used to gather information from tickets, put them in the proper directory, and close
# the tickets
#Author: Katie Swinea
#Creation Date: 4/27/2024

#used to update the machine once for software packages in the ticket
sudo apt-get update
strURLArray=$(curl https://www.swollenhippo.com/ServiceNow/systems/devTickets.php)
#debug statment to test for curled objects
#echo ${strURLArray}
intArrayLength=$(echo ${strURLArray} | jq 'length')
#debug statment to ensure the length has been determined
#echo $intArrayLength
iteration=0
mkdir configurationLogs

while [ "$iteration" -lt "$intArrayLength" ];
do
strTicketID=$(echo ${strURLArray} | jq -r .[${iteration}].ticketID)
#debug statement used to output the ticket Id was extracted for each object in the array
#echo $strTicketID

if [ "$strTicketID" == "$1" ]; then
strLogTitle="$strTicketID.log"
#debug statment to ensure the title of the log file was created properly
#echo $strLogTitle
echo "TicketID: $strTicketID" >> configurationLogs/$strLogTitle
strDate=$(date +"%d-%b-%Y %H:%M")
#debug statment to ensure the date is formatted correctly
#echo $strDate
echo "Start DateTime: $strDate" >> configurationLogs/$strLogTitle
strRequestor=$(echo ${strURLArray} | jq -r .[${iteration}].requestor)
#debug statement to ensure the requestor was recieved
#echo $strRequestor
echo "Requestor: $strRequestor" >> configurationLogs/$strLogTitle
#external ip address is input as a parameter and can be passed directly to the file
echo "External IP Address: $2" >> configurationLogs/$strLogTitle
strHostname=$(echo $HOSTNAME)
#debug statement to ensure the hostname has been stored in the variable
#echo $strHostname
echo "Hostname: strHostname" >> configurationLogs/$strLogTitle
strStandardConfig=$(echo ${strURLArray} | jq -r .[${iteration}].standardConfig)
#debug staement to see the standard configuration for the file
#echo $strStandardConfig
strSoftwarePackages=$(echo ${strURLArray} | jq -r .[${iteration}].softwarePackages)
intSoftwarePackages=$(echo ${strSoftwarePackages} | jq 'length')
intSoftwareCheck=0

#while loop is used to go through the software packages in the ticket if applicable
while [ "$intSoftwareCheck" -lt "$intSoftwarePackages" ];
do
strTask=$(echo ${strSoftwarePackages} | jq -r .[$intSoftwareCheck].name)
#debug statement to check the while loop functionality and display the software to be installed
#echo $strTask
strSoftwareInstall=$(echo ${strSoftwarePackages} | jq -r .[$intSoftwareCheck].install)
#debug statement to ensure the install packages is being etracted properly
#echo $strSoftwareInstall
strTimeStamp=$(date +"%s")
#debug statement to ensure the timestamp is correct
#echo $strTimeStamp
echo "$strTask - $strSoftwareInstall - $strTimeStamp" >> configurationLogs/$strLogTitle
#used to install the specified packages
sudo apt-get install $strSoftwareInstall -y
((intSoftwareCheck++))
done

fi

((iteration++))
done

#! /bin/bash

#Description: A file used to gather information from tickets in a log file, put the log file in the proper
# directory, and close the tickets. The tickets software installations and configurations are also handled
# through this script The version of any downloaded software is included in the log for the ticket. The
# desired ticket is searched for in the array of tickets from the provided URL.
#Author: Katie Swinea
#Creation Date: 4/27/2024

#used to update the machine once for software packages in the ticket
sudo apt-get update
#since jq is used within the shellscript, it needs to be installed
sudo apt-get install jq
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

if [ "$strTicketID" == "$2" ]; then
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
echo "External IP Address: $1" >> configurationLogs/$strLogTitle
strHostname=$(echo $HOSTNAME)
#debug statement to ensure the hostname has been stored in the variable
#echo $strHostname
echo "Hostname: $strHostname" >> configurationLogs/$strLogTitle
strStandardConfig=$(echo ${strURLArray} | jq -r .[${iteration}].standardConfig)
#debug staement to see the standard configuration for the file
#echo $strStandardConfig
echo "Standard Configuration: $strStandardConfig" >> configurationLogs/$strLogTitle

#used to get the information about software installations if applicable
strSoftwarePackages=$(echo ${strURLArray} | jq -r .[${iteration}].softwarePackages)
intSoftwarePackages=$(echo ${strSoftwarePackages} | jq 'length')
intSoftwareCheck=0
intVersionCheck=0

#while loop is used to go through the software packages in the ticket if applicable
while [ "$intSoftwareCheck" -lt "$intSoftwarePackages" ];
do
strTask=$(echo ${strSoftwarePackages} | jq -r .[$intSoftwareCheck].name)
#debug statement to check the while loop functionality and display the software to be installed
#echo $strTask
strSoftwareInstall=$(echo ${strSoftwarePackages} | jq -r .[$intSoftwareCheck].install)
#debug statement to ensure the install packages is being extracted properly
#echo $strSoftwareInstall
strTimeStamp1=$(date +"%s")
#debug statement to ensure the timestamp is correct
#echo $strTimeStamp1
echo "softwarePackage - $strTask - $strTimeStamp1" >> configurationLogs/$strLogTitle
#used to install the specified packages
sudo apt-get install $strSoftwareInstall -y
((intSoftwareCheck++))
done

strAdditionalConfigs=$(echo ${strURLArray} | jq -r .[${iteration}].additionalConfigs)
intAdditionalConfigs=$(echo ${strAdditionalConfigs} | jq 'length')
intAddConfigCount=0

#while loop is used to go through the additional configurations in the ticket if applicable
while [ "$intAddConfigCount" -lt "$intAdditionalConfigs" ];
do
strConfigTask=$(echo ${strAdditionalConfigs} | jq -r .[$intAddConfigCount].name)
#debug statement to check the while loop functionality and display the title of the configuration
#echo $strConfigTask
strConfiguration=$(echo ${strAdditionalConfigs} | jq -r .[$intAddConfigCount].config)
#debug statement to ensure the configuration has been recieved
#echo $strConfiguration
strTimeStamp2=$(date +"%s")
#debug statement to ensure the timestamp is correct
#echo $strTimeStamp2
echo "additionalConfig - $strConfigTask - $strTimeStamp2" >> configurationLogs/$strLogTitle
#used to perform the configurations
strDirectoryPath=$(dirname $strConfiguration)
#debug statement to ensure the path to the directory was properly extracted from the text
#echo $strDirectoryPath
strDirectories=$(echo $strDirectoryPath | cut -d '/' -f2-)
#debug statement to ensure the contents of the mkdir command are formatted properly
#echo $strDirectories

#if statement used to determine if there is a diretory path that needs to be created
if [ "$strDirectories" != "" ]; then
mkdir -p $strDirectories
fi

strFinalConfiguration=$(echo $strConfiguration | sed 's#/##')
#debug statement to ensure the first slash is removed becasue it ruins every command that tries to use it
#echo $strFinalConfiguration
eval ${strFinalConfiguration}
((intAddConfigCount++))
done

#while loop is used to go through the software installed for a version check
while [ "$intVersionCheck" -lt "$intSoftwarePackages" ];
do
strSoftwareDescription=$(echo ${strSoftwarePackages} | jq -r .[$intVersionCheck].name)
#debug statement to ensure the description of the software that was installed
#echo strSoftwareDescription
strSoftwareInstalled=$(echo ${strSoftwarePackages} | jq -r .[$intVersionCheck].install)
#debug statement to ensure the install packages is being extracted properly
#echo $strSoftwareInstalled
strVersion=$(apt show $strSoftwareInstalled | grep -i version | awk '{print $2}')
#debug statement to ensure the version information was extracted
#echo $strVersion
intVersion=$(echo $strVersion | sed 's/^[^:]*://' | cut -d'-' -f1)
#debug statement to ensure the version is being formatted correctly
#echo $intVersion
echo "Version Check - $strSoftwareDescription - $intVersion" >> configurationLogs/$strLogTitle
((intVersionCheck++))
done

#used for closing the ticket
strBaseTicketCloseURL="https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID="
strTicketClose="$strBaseTicketCloseURL$2"
strTicketCloseResult=$(curl $strTicketClose)
#debug statement to ensure the ticket's closing url was curled correctly
#echo $strTicketCloseResult
strTicketResult=$(echo ${strTicketCloseResult} | jq -r .outcome)
echo $strTicketResult >> configurationLogs/$strLogTitle
strEndTime=$(date +"%d-%b-%Y %H:%M")
echo "Completed: $strEndTime" >> configurationLogs/$strLogTitle
fi

((iteration++))
done

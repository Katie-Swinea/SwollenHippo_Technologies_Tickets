#! /bin/bash

#Description: A file used to gather information from tickets, put them in the proper directory, and close
# the tickets
#Author: Katie Swinea
#Creation Date: 4/27/2024

strURLArray=$(curl https://www.swollenhippo.com/ServiceNow/systems/devTickets.php)
#debug statment to test for curled objects
#echo ${strURLArray}
intArrayLength=$(echo ${strURLArray} | jq 'length')
#debug statment to ensure the length has been determined
echo $intArrayLength
iteration=0

while [ "$iteration" -lt "$intArrayLength" ];
do
strTicketID=$(echo ${strURLArray} | jq -r .[${iteration}].ticketID)
#debug statement used to output the ticket Id was extracted for each object in the array
echo $strTicketID
((iteration++))
done

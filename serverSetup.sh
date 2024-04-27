#! /bin/bash

#Description: A file used to gather information from tickets, put them in the proper directory, and close
# the tickets
#Author: Katie Swinea
#Creation Date: 4/27/2024

strURLArray=$(curl https://www.swollenhippo.com/ServiceNow/systems/devTickets.php)
#debug statment to test for curled objects
echo ${strURLArray}

#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
#printf "I ${RED}love${NC} coding\n"
#echo -e "I ${RED}love${NC} coding\n"


# Root/Sudo checker
if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}-----------------------------${NC}" 1>&2
        echo -e "${RED}You must be root to run this.${NC}" 1>&2
        echo -e "${RED}-----------------------------${NC}" 1>&2
        exit 100
fi

echo ""
echo -e "${YELLOW}"
echo "         ###    ##       ##     ##    ###   "
echo "        ## ##   ##       ###   ###   ## ##  "
echo "       ##   ##  ##       #### ####  ##   ## "
echo "      ##     ## ##       ## ### ## ##     ##"
echo "      ######### ##       ##     ## #########"
echo "      ##     ## ##       ##     ## ##     ##"
echo "      ##     ## ######## ##     ## ##     ##"
echo "      --------EMAIL2PRINT GATEWAY-----------"
echo -e "${NC}"
echo ""


while IFS=, read user ip
do
        #
        # Validate user/printer name
        # Ensure the name does not have spaces/underscores/foreign characters.
        # Only hyphens and [a-z|0-9]
        # Convert to lower case - Mail will not route if the user account name is in capital letters
        #
        userLower=$(echo "$user" | sed 's/.*/\L&/')


        #
        #
        #
        #
        function validateIP()
        {
                local ip=$1
                local stat=1
                if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        OIFS=$IFS
                        IFS='.'
                        ip=($ip)
                        IFS=$OIFS
                        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
                        && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
                        stat=$?
                fi

                return $stat
        }

        #
        # Output username to screen
        #
        echo -e "---------------------------------------------------------------" 1>&2
        echo "User account - $userLower"
        echo "Printer name - $userLower"
        echo "Printer IP   - $ip"
        echo -e "" 1>&2

        validateIP $ip
        if [[ $? -ne 0 ]]; then
                echo -e "${RED}Invalid IP address. Please check the csv file and try again${NC}"
        else
                #
                # Let's check to see if the user alredy exists
                #
                if id "$userLower" >/dev/null 2>&1; then
                        echo -e "" 1>&2
                        echo -e "${RED}User account $userLower already exists. No account created${NC}"
                        echo -e "" 1>&2
                else
                        echo -e "${GREEN}User account $userLower does not exist. Creating account.${NC}"

                        # Add user - without password
                        useradd $userLower

                        # Add printer
                        echo -e "${GREEN}Creating printer $user${NC}"
                        lpadmin -p $userLower -v lpd://$ip -E

                        # Copy .procmailrc to user home directory
                        echo -e "${GREEN}Copying .procmailrc to $user home directory${NC}"
                        cp /usr/local/bin/ALMA-Deployment/procmail/.procmailrc /home/$userLower/.procmailrc
                fi

        fi


        echo "---------------------------------------------------------------" 1>&2

done < add_printers.csv

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

while IFS=, read user
do
        #
        # Convert to lower case - Mail will not route if the user account name is in capital letters
        #
        userLower=$(echo "$user" | sed 's/.*/\L&/')

        #
        # Output username to screen
        #
        echo -e "${YELLOW}---------------------------------------------------------------" 1>&2
        echo "User account - $userLower"
        echo "Printer name - $userLower"
        echo -e "---------------------------------------------------------------${NC}" 1>&2

        #
        # Let's check to see if the user alredy exists
        #
        if id "$userLower" >/dev/null 2>&1; then
                echo -e "${GREEN}User account $userLower exists. Deleting account, files and MAIL file.${NC}"

                # Delete user, home directory and associated files
                userdel -r $userLower

                # Add printer
                echo -e "${GREEN}Removing printer $user${NC}"
                lpadmin -x $userLower
        else
                echo -e "${RED}----------------------------------------------------------${NC}" 1>&2
                echo -e "${RED}User account $userLower does not exist. No account deleted${NC}"
                echo -e "${RED}----------------------------------------------------------${NC}" 1>&2
        fi

        echo "---------------------------------------------------------------" 1>&2
        echo "---------------------------------------------------------------" 1>&2

done < del_printers.csv
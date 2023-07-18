#!/bin/bash

#?:'######::'########:'########:'##::::'##:'########::'########::'####:'##::: ##::::'###:::::'######::
#?'##... ##: ##.....::... ##..:: ##:::: ##: ##.... ##: ##.... ##:. ##:: ###:: ##:::'## ##:::'##... ##:
#? ##:::..:: ##:::::::::: ##:::: ##:::: ##: ##:::: ##: ##:::: ##:: ##:: ####: ##::'##:. ##:: ##:::..::
#?. ######:: ######:::::: ##:::: ##:::: ##: ########:: ########::: ##:: ## ## ##:'##:::. ##:. ######::
#?:..... ##: ##...::::::: ##:::: ##:::: ##: ##.....::: ##.....:::: ##:: ##. ####: #########::..... ##:
#?'##::: ##: ##:::::::::: ##:::: ##:::: ##: ##:::::::: ##::::::::: ##:: ##:. ###: ##.... ##:'##::: ##:
#?. ######:: ########:::: ##::::. #######:: ##:::::::: ##::::::::'####: ##::. ##: ##:::: ##:. ######::
#?:......:::........:::::..::::::.......:::..:::::::::..:::::::::....::..::::..::..:::::..:::......:::

#############################################################################################################
#Script Name	:   setupRaspberryPI_NAS.sh                                                                                           
#Description	:   After adjusting the qualities of Password, Username, and the Name of the PI you are using    
#                   this script should connect to the PI vis SSH and install Open Media Vault so the PI
#                   can be used as a Network Access Storage                                                                                                                                                       
#Author       	:   Ryan Woodward                                               
#Email         	:   ryanjwoodward@outlook.com                                           
##############################################################################################################

# Function to get the IP address of a specific device
get_device_ip() {
    local device_name="$1"
    local ip_address
    ip_address=$(nmap -sn "$network_range" | grep "$device_name" -B2 | grep -oP '(?<=for\s)[0-9.]+')
    echo "$ip_address"
}

# Check if sshpass is installed, if not, install it
if ! command -v sshpass &>/dev/null; then
    echo "Installing sshpass..."
    yay -S sshpass  # Replace 'yay' with your AUR helper (e.g., yay, paru, etc.)
fi

# Get the IP addresses using the ip command
ip_addresses=$(ip -4 address show up | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Print the IP addresses
echo "Your IP addresses are:"
echo "$ip_addresses"

# Get the IP address range for the local network
network_range=$(ip -4 route | awk '/default/ {print $3}' | awk -F"." '{print $1"."$2"."$3".0/24"}')

# Run Nmap to scan each IP address within the local network
echo "Running Nmap scans on the local network..."
for ip in $ip_addresses; do
    nmap -sn "$network_range" -exclude "$ip"
done

# Get the IP address of the Raspberry Pi and store it in a variable
raspberry_ip=$(get_device_ip "<WHATEVER YOU NAMED YOU PI>")
echo "IP address of 'raspberry' device: $raspberry_ip"

# SSH into the Raspberry Pi and run the wget command
if [ -n "$raspberry_ip" ]; then
    echo "Connecting to Raspberry Pi..."
    sshpass -p "<PASSWORD TO YOUR PI" ssh -o StrictHostKeyChecking=no <USER WITH ACCESS TO PI>@"$raspberry_ip" "wget -O - https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install | sudo bash"
else
    echo "Could not find IP address for 'raspberry' device."
fi

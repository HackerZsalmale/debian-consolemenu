#!/bin/bash

# Ensure IP address is captured cleanly
IP_ADDRESS=$(hostname -I | awk '{print $1}')

while true; do
    clear
    echo "=============================="
    echo "         OPTION MENU          "
    echo "=============================="
    echo "1. Run fastfetch"
    echo "2. Start System Stat website"
    echo "3. Update System && Upgrade"
    echo "4, Speedtest"
    echo "5. Exit"
    echo "=============================="
    read -p "Enter your choice [1-4]: " choice

    case $choice in
        1)
            echo ""
            if ! command -v fastfetch &> /dev/null; then
                echo "Installing fastfetch..."
                sudo apt install -y fastfetch
            fi
            fastfetch
            ;;
        2)
            echo ""
            echo "Setting up and starting System Stat website..."
            

            sudo apt install -y git npm python3
            if ! command -v pm2 &> /dev/null; then
                sudo npm install -g pm2
            fi

            sudo mkdir -p /qandor
            cd /qandor || exit


            if [ ! -d "raspberry-statpage" ]; then
                sudo git clone https://github.com/HackerZsalmale/raspberry-statpage
            else
                echo "Repository already exists, pulling updates..."
                cd raspberry-statpage && sudo git pull && cd ..
            fi

            cd raspberry-statpage || exit


            if [ -f "package.json" ]; then
                sudo npm install
            fi

            if command -v ufw &> /dev/null; then
                sudo ufw allow 3000/tcp
                sudo ufw reload
            fi


            pm2 delete all 2>/dev/null
            pm2 start stats.py --name "pi-stats" --interpreter python3
            pm2 start server.js --name "pi-server"
            pm2 save

            echo ""
            echo "Website is running at:"
            echo "  http://localhost:3000"
            echo "  http://${IP_ADDRESS}:3000"
            ;;
        3)
            echo ""
            echo "Updating system packages..."
            sudo apt update && sudo apt upgrade -y
            ;;
        4)
            echo "Exiting menu..."
            exit 0
            ;;

        5)
            echo "Speedtest in progress..."
            clear
            speedtest-cli
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac

    echo ""
    read -p "Press [Enter] key to return to the menu..." temp
done

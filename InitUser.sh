#!/bin/bash

# Define color variables
GREEN='\033[0;32m'  # Green color
YELLOW='\033[1;33m' # Yellow color
NC='\033[0m'        # No color (reset)


if (( $# != 2 )); then
    echo "usage: $0 UserName Password"
    exit 0
fi

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

Username=$1
Password=$2


# Setting up Keyboard
echo -e "${YELLOW}[?] Reconfiguring Keyboard...${NC}"
setxkbmap fr
# Force non-interactive mode
export DEBIAN_FRONTEND=noninteractive

sudo debconf-set-selections <<EOF
keyboard-configuration keyboard-configuration/layoutcode string fr
keyboard-configuration keyboard-configuration/modelcode string pc105
keyboard-configuration keyboard-configuration/variantcode string
keyboard-configuration keyboard-configuration/xkb-keymap select fr
keyboard-configuration keyboard-configuration/layout select French
keyboard-configuration keyboard-configuration/variant select Français
EOF

sudo dpkg-reconfigure keyboard-configuration --frontend noninteractive

sudo systemctl restart keyboard-setup.service
sudo setupcon
echo -e "${GREEN}[>] Reconfiguring Keyboard!${NC}"

# Creating user
echo -e "${YELLOW}[?] Adding new user ${Username}..${NC}"
echo -e "[+] Creating user"
sudo useradd -m $Username
echo -e "[+] Setting password"
echo $Password > ~/.password
echo $Password >> ~/.password
sudo passwd $Username < ~/.password
sudo rm ~/.password
echo -e "[+] Adding Groups"
sudo usermod -aG kali,adm,dialout,cdrom,floppy,sudo,audio,dip,video,plugdev,users,netdev,bluetooth,scanner,wireshark,kaboxer $Username

echo -e "[+] Customizing shell"
sudo sed -i "s\/home/$Username:/bin/sh\/home/$Username:/usr/bin/zsh\g" /etc/passwd

echo -e "[+] Customizing shell start file"
sudo mkdir /home/$Username/konsole_logs
sudo chown $Username /home/$Username/konsole_logs 
sudo chgrp $Username /home/$Username/konsole_logs

curl -L "https://github.com/Fropops/CustomKali/raw/refs/heads/main/zshrc" -o "zshrc"
sudo mv -f zshrc /home/$Username/.zshrc
sudo chown $Username /home/$Username/.zshrc 
sudo chgrp $Username /home/$Username/.zshrc

# Configure shared folder
echo -e "${YELLOW}[?] Configuring Shared folder...${NC}"
sudo mkdir /mnt/Share
sudo /usr/bin/vmhgfs-fuse .host:/Share /mnt/Share -o subtype=vmhgfs-fuse,allow_other 
sudo echo ".host:/Share /mnt/Share fuse.vmhgfs-fuse defaults,allow_other 0 0" >> /etc/fstab
echo -e "${GREEN}[>] Share configured!${NC}"

# Cleaning 
echo -e "${YELLOW}[?] Cleaning...${NC}"
sudo rm install.sh
echo -e "${GREEN}[>] Cleaning done!${NC}"

# End of the script, restart
echo -e "${YELLOW}[?] Restarting in 15 sec...${NC}"
echo -e "${GREEN}[>] You can now log as $Username and complete the installation !${NC}"
sleep 15
/sbin/shutdown -r now


#!/bin/bash

# Define color variables
GREEN='\033[0;32m'  # Green color
YELLOW='\033[1;33m' # Yellow color
NC='\033[0m'        # No color (reset)


if (( $# != 2 )); then
    echo "usage: $0 UserName Password"
    exit 0
fi

[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"ls -lat


Username=$1
Password=$2


# Setting up Keyboard
echo -e "${YELLOW}[?] Reconfiguring Keyboard...${NC}"
# Force non-interactive
export DEBIAN_FRONTEND=noninteractive

echo "[*] Config TTY keyboard (console)..."
cat <<EOF | debconf-set-selections
keyboard-configuration  keyboard-configuration/layoutcode string fr
keyboard-configuration  keyboard-configuration/modelcode  string pc105
keyboard-configuration  keyboard-configuration/variant    select oss
keyboard-configuration  keyboard-configuration/optionscode string
EOF

dpkg-reconfigure keyboard-configuration --frontend noninteractive

# TTY reload
systemctl restart keyboard-setup.service || true

echo "[*] Config X11 keyboard..."
mkdir -p /etc/X11/xorg.conf.d

cat <<EOF >/etc/X11/xorg.conf.d/00-keyboard.conf
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "fr"
        Option "XkbModel" "pc105"
        Option "XkbVariant" "oss"
EndSection
EOF

echo "[*] Applying X11 keymap..."
setxkbmap fr

echo "[+] Keyboard set to French (TTY + X11). Logout or reboot to apply fully."
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
old_user="kali"
new_user="$Username"

for grp in $(id -nG "$old_user"); do
    sudo usermod -a -G "$grp" "$new_user"
done

echo -e "[+] Customizing shell"
sudo sed -i "s\/home/$Username:/bin/sh\/home/$Username:/usr/bin/zsh\g" /etc/passwd

echo -e "[+] Customizing shell start file"
sudo mkdir /home/$Username/konsole_logs
sudo chown "$Username":"$Username" /home/$Username/konsole_logs 

curl -L "https://github.com/Fropops/CustomKali/raw/refs/heads/main/zshrc" -o "zshrc"
sudo mv -f zshrc /home/$Username/.zshrc
sudo chown "$Username":"$Username" /home/$Username/.zshrc 

# Configure shared folder
echo -e "${YELLOW}[?] Configuring Shared folder...${NC}"
sudo mkdir /mnt/Share
sudo /usr/bin/vmhgfs-fuse .host:/Share /mnt/Share -o subtype=vmhgfs-fuse,allow_other 
sudo echo ".host:/Share /mnt/Share fuse.vmhgfs-fuse defaults,allow_other 0 0" >> /etc/fstab
echo -e "${GREEN}[>] Share configured!${NC}"

echo -e "${YELLOW}[?] Updating System...${NC}"
echo "[*] Updating package lists..."
sudo apt update -y


echo -e "${YELLOW}[?] Installing Programs...${NC}"
# Install Konsole
echo -e "[+] Installing Konsole"
sudo apt-get update
sudo apt-get -y install konsole
#replace terminal by konsole instance for new users (shortcut)
sudo sed -i 's|Exec=exo-open --launch TerminalEmulator|Exec=konsole|g' "/usr/share/applications/xfce4-terminal-emulator.desktop"

echo -e "[+] Updating Profiles"
curl -L "https://github.com/Fropops/CustomKali/raw/refs/heads/main/profile.zip" -o "profile.zip"
unzip profile.zip
mkdir /home/$Username/.local/share/konsole/
mv *.profile /home/$Username/.local/share/konsole/
mv *.colorscheme /home/$Username/.local/share/konsole/
rm profile.zip

# Install Visual Studio Code
echo -e "[+] Installing  jq"
sudo apt update
sudo apt install -y jq

# Install Visual Studio Code
echo -e "[+] Installing  Visual Studio Code"
echo "[*] Adding Microsoft GPG key..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/microsoft.gpg > /dev/null

echo "[*] Adding VS Code repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/vscode stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

# Update package list
echo "[*] Updating package list..."
sudo apt update

echo "[*] Installing VS Code..."
sudo apt install -y code

echo "[+] VS Code installed successfully!"


# Install .Net
echo -e "[+] Installing .Net"
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y dotnet-sdk-7.0

# Install Rust
echo -e "[+] Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rust-install.sh
chmod +x rust-install.sh
./rust-install.sh -y
rm rust-install.sh
~/.cargo/bin/rustup target add i686-pc-windows-gnu
~/.cargo/bin/rustup target add x86_64-pc-windows-gnu

# Install Donut
echo -e "[+] Installing Donut"
sudo chmod 777 /opt
cd /opt
git clone http://github.com/thewover/donut.git
cd /opt/donut
make

echo -e "${GREEN}[>] Programs installed!${NC}"


# End of the script, restart
echo -e "${YELLOW}[?] Restarting in 15 sec...${NC}"
echo -e "${GREEN}[>] You can now log as $Username and complete the installation !${NC}"
sleep 15
/sbin/shutdown -r now


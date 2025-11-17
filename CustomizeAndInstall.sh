#!/bin/bash

pwd=$PWD

# Define color variables
GREEN='\033[0;32m'  # Green color
YELLOW='\033[1;33m' # Yellow color
NC='\033[0m'        # No color (reset)

echo -e "${YELLOW}[?] Installing Programs...${NC}"
# Install Konsole
echo -e "[+] Installing Konsole"
sudo apt-get update
sudo apt-get -y install konsole
#used to change the menu entry
#sudo sed -i "s/Exec=.*$/Exec=konsole/g" xfce4-terminal-emulator.desktop
sudo sed -i "s/Exec=exo-open --launch TerminalEmulator/Exec=konsole/g" /home/$USER/.config/xfce4/panel/launcher-7/*

echo -e "[+] Updating Profiles"
curl -L "https://github.com/Fropops/CustomKali/raw/refs/heads/main/profile.zip" -o "profile.zip.zip"
unzip profile.zip
mkdir /home/$USER/.local/share/konsole/
mv *.profile /home/$USER/.local/share/konsole/
mv *.colorscheme /home/$USER/.local/share/konsole/
rm profile.zip

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

echo "[*] Updating package lists..."
sudo apt update -y

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

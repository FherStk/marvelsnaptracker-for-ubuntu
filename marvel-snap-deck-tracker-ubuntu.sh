#!/bin/bash
VERSION="0.0.5"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)

source $SCRIPT_PATH/utils/main.sh

echo ""
echo -e "${YELLOW}Ubuntu binary builder for the Marvel Snap Deck Tracker${NC} (v$VERSION)"
echo -e "${YELLOW}Copyright © 2023:${NC} Fernando Porrino Serrano"
echo -e "${YELLOW}Under the AGPL license:${NC} https://github.com/FherStk/marvelsnaptracker-forubuntu/blob/main/LICENSE"
echo
echo -e "${PURPLE}Attention please:${NC} This is an Ubuntu binary builder for the Marvel Snap Deck Tracker by ${LCYAN}Razviar${NC}, please visit ${LCYAN}https://github.com/Razviar/marvelsnaptracker${NC} for further information."

trap 'abort' 0

#Checking for "sudo"
if [ "$EUID" -ne 0 ]
then 
    echo ""
    echo -e "${RED}Please, run with 'sudo'.$NC"

    trap : 0
    exit 0
fi    

#Update if new versions  
auto-update true

echo ""
title "Updating apt sources:"
apt update

apt-install lxc

echo ""
title "Setting up the LXC/LXD container:"    
if [ $(lxc storage list | grep -c "CREATED") -eq 0 ];
then    
    echo "Initializing the LXC/LXD container..."
    lxd init --auto
else
    echo "LXC/LXD container already initialized, skipping..."
fi

_container="marvel-snap-deck-tracker-builder"
if [ $(lxc list | grep -c "$_container") -eq 0 ];
then    
    lxc launch ubuntu:22.04 $_container
else
    echo "LXC/LXD image already exists, skipping..."
fi

echo
title "Building the binary:"
echo "Copying the build script within the container..."
lxc file push --recursive $SCRIPT_PATH ${_container}/etc/

echo "Running the build script within the container..."
lxc exec $_container -- /bin/bash /etc/marvelsnaptracker-forubuntu/utils/build.sh

echo
echo "Copying the binary to the local host..."
lxc file pull $_container/root/marvelsnaptracker/out/'Marvel Snap Tracker-linux-x64' ./build --recursive

echo ""
echo -e "${GREEN}Done! You'll find the binary into the /build folder, run it with './Marvel\ Snap\ Tracker'{$NC}"
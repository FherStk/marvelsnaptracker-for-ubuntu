#!/bin/bash
VERSION="0.0.1"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)

source $SCRIPT_PATH/utils/main.sh

echo ""
echo -e "${YELLOW}Ubuntu Builder for the Marvel Snap Deck Tracker${NC} (v$VERSION)"
echo -e "${YELLOW}Copyright © 2023:${NC} Fernando Porrino Serrano"
echo -e "${YELLOW}Under the AGPL license:${NC} https://github.com/FherStk/marvelsnaptracker-forubuntu/blob/main/LICENSE"
echo
echo -e "${CYAN}This is an Ubuntu builder for the Marvel Snap Deck Tracker by ${LCYAN}Razviar${CYAN}, please visit ${LCYAN}https://github.com/Razviar/marvelsnaptracker${CYAN} for further information.${NC}"
echo

trap 'abort' 0

echo ""
title "Updating apt sources:"
apt update

echo ""
title "Installing dependencies:"
apt-install lxc

echo ""
title "Setting up the LXC/LXD container:"    
if [ $(lxc list | grep -c "lxd init") -eq 1 ];
then    
    echo ""
    title "Initializing the LXC/LXD container..."
    lxd init --auto
else
    echo ""
    echo -e "${CYAN}LXC/LXD container already initialized, skipping...$NC"
fi

_container="marvel-snap-deck-tracker-builder"
lxc launch ubuntu:22.04 $_container

title "Building the binary:"
echo "Copying the build script within the container..."
lxc file push --recursive $SCRIPT_PATH ${_container}/etc/

echo "Running the build script within the container..."
lxc exec $_container -- /bin/bash /etc/marvelsnaptracker-forubuntu/utils/build.sh

echo "Copying the binary to the local host..."
lxc file pull marvel-snap-deck-tracker/root/marvelsnaptracker/out/'Marvel Snap Tracker-linux-x64' ./build --recursive

echo "Cleaning..."
lxc stop $_container
lxc delete $_container

echo ""
echo -e "${GREEN}Done! You'll find the binary into the /build folder, run it with './Marvel\ Snap\ Tracker'{$NC}"
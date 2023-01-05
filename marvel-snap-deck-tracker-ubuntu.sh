#!/bin/bash
VERSION="1.1.0"

SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SCRIPT_FILE=$(basename $BASH_SOURCE)
INSTALL_PATH="/etc/marvel-snap-tracker/"

source $SCRIPT_PATH/utils/main.sh

echo ""
echo -e "${YELLOW}Ubuntu binary builder for the Marvel Snap Deck Tracker${NC} (v$VERSION)"
echo -e "${YELLOW}Copyright © 2023:${NC} Fernando Porrino Serrano"
echo -e "${YELLOW}Under the AGPL license:${NC} https://github.com/FherStk/marvelsnaptracker-for-ubuntu/blob/main/LICENSE"
echo
echo -e "${LPURPLE}Attention please:${NC} This is an Ubuntu binary builder for the Marvel Snap Deck Tracker by ${LCYAN}Razviar${NC}, please visit ${LCYAN}https://github.com/Razviar/marvelsnaptracker${NC} for further information."

#Checking for "sudo"
if [ "$EUID" -ne 0 ]
then 
    echo ""
    echo -e "${RED}Please, run with 'sudo'.${NC}"

    trap : 0
    exit 0
fi    

trap 'abort' 0

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

container="marvel-snap-deck-tracker-builder"
if [ $(lxc list | grep -c "$container") -eq 0 ];
then    
    lxc launch ubuntu:22.04 $container
else
    echo "LXC/LXD image already exists, skipping..."
fi

echo
title "Building the binary:"
echo "Copying the build script within the container..."
lxc file push --recursive $SCRIPT_PATH ${container}/etc/

echo "Running the build script within the container..."
lxc exec $container -- /bin/bash /etc/marvelsnaptracker-for-ubuntu/utils/build.sh

echo
echo "Copying the binary to the local host..."
lxc file pull $container/root/marvelsnaptracker/out/'Marvel Snap Tracker-linux-x64' . --recursive

echo "Setting up permissions..."
rm -rf build
mv Marvel\ Snap\ Tracker-linux-x64/ build
chown -R $SUDO_USER:$SUDO_USER build 

echo
question "Do you want to install the application? " "[Y/n]"
read input

if [[ "$input" == "n" ]];
then        
    done-ok
else
    if [ ! -z "$input" ];
    then        
        echo
    fi  
    
    question "Please, set the installation path: " "[$INSTALL_PATH]"
    read input

    if [ -z "$input" ];
    then        
        input=$INSTALL_PATH
    else
        echo
    fi

    title "Installing the app into " $input ":"    
    echo "Creating the destination folder..."
    mkdir -p $input
    
    echo "Copying files..."
    cp -Rf build/* $input

    echo "Creating a shortcut into the app list..."    
    dst="utils/marvel-snap-tracker.desktop"
    src="${dst}.template"

    cp -f $src $dst
    echo "PATH: $input"

    sed -i "s|<INSTALL_PATH>|$input|g" $dst
    chown -R $SUDO_USER:$SUDO_USER $dst  
    run-in-user-session xdg-desktop-menu install $dst
    rm $dst
fi

done-ok
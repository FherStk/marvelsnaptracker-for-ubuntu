#!/bin/bash
SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPT_PATH/./main.sh

echo ""
title "Updating apt sources:"
apt update

title "Installing dependencies:"
apt-install "curl"
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - 

apt-install "nodejs"
apt-install "build-essential"
apt-install "clang"
apt-install "libdbus-1-dev"
apt-install "libgtk-3-dev"
apt-install "ibnotify-dev"
apt-install "libasound2-dev"
apt-install "libcap-dev"
apt-install "libcups2-dev"
apt-install "libxtst-dev"
apt-install "libxss1"
apt-install "libnss3-dev"
apt-install "gcc-multilib"
apt-install "g++-multilib"
apt-install "gperf"
apt-install "bison"
apt-install "python3-dbusmock"
apt-install "openjdk-8-jre"

title "Downloading the Marvel Snap Deck Tracker:"
git clone https://github.com/Razviar/marvelsnaptracker.git
cd marvelsnaptracker

title "Setting up the build environment:"
npm install -g pkg electron-forge
npm audit fix

title "Building the binary:"
npm run package
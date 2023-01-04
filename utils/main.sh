#!/bin/bash

# Terminal colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

title(){
  ####################################################################################
  #Description: Displays a title caption using the correct colors. 
  #Input:  $1 => Main caption | $2 => secondary caption
  #Output: N/A
  ####################################################################################

  echo -e "${LCYAN}${1}${CYAN}${2}${NC}"
}

apt-install()
{
  ####################################################################################
  #Description: Unnatended package install (if not installed) using apt.
  #Input:  $1 => The app name
  #Output: N/A
  ####################################################################################  

  echo ""
  if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then    
    title "Installing apt package: " "$1"
    DEBIAN_FRONTEND=noninteractive apt install -y $1;    
  else 
    echo -e "${CYAN}Package ${LCYAN}${1}${CYAN} already installed, skipping...$NC"
  fi
}

auto-update()
{
  ####################################################################################
  #Description: Updates this app and restarts it.
  #Input:  $1 => If 'true' then restarts the app
  #Output: N/A
  ####################################################################################     

  echo ""
  title "Checking for a new app version: "
  get-branch

  if [ $(LC_ALL=C git -C $BASE_PATH status -uno | grep -c "Your branch is up to date with 'origin/$CURRENT_BRANCH'") -eq 1 ];
  then     
    echo -e "Up to date, skipping..."
  else
    echo "" 
    echo -e "${CYAN}New version found, updating...$NC"
    git -C $BASE_PATH reset --hard origin/$CURRENT_BRANCH
    echo "Update completed." 

    if [ $1 = true ]; 
    then
      echo "Restarting the app..."
    
      trap : 0
      bash $SCRIPT_PATH/$SCRIPT_FILE
      exit 0
    fi
  fi
}

get-branch()
{
  ####################################################################################
  #Description: Loads the current git branch.
  #Input:  N/A
  #Output: CURRENT_BRANCH => The current git branch
  #################################################################################### 

  echo -e "Getting the current branch info..."
  git -C $BASE_PATH fetch --all
  CURRENT_BRANCH=$(git -C $BASE_PATH rev-parse --abbrev-ref HEAD)
}

abort()
{ 
  ####################################################################################
  #Description: Used by "trap" in order to display the error message in red. 
  #Source: https://stackoverflow.com/a/22224317      
  #Input:  N/A
  #Output: N/A
  ####################################################################################

  echo ""
  echo -e "${RED}An error occurred. Exiting...$NC" >&2
  exit 1
}
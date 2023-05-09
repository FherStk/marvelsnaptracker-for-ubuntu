# Marvel Snap Tracker for Ubuntu
An Ubuntu binary builder and installer for the Marvel Snap Tracker by Razviar (https://github.com/Razviar/marvelsnaptracker)

It has been tested on:
* Ubuntu 22.04 LTS
* Ubuntu 21.10
* Mint 21.1

## How to run this app (Mint)
1. Open a terminal.
2. Run `sudo rm /etc/apt/preferences.d/nosnap.pref`
3. Run `sudo apt install snapd && sudo snap install core && sudo snap install lxd`
4. Follow the "Ubuntu" steps.

## How to run this app (Ubuntu)
1. Open a terminal.
1. Clone the repository localy with `git clone https://github.com/FherStk/marvelsnaptracker-for-ubuntu.git`.
1. Go inside the repository with `cd marvelsnaptracker-for-ubuntu`
1. Run the app with `./marvel-snap-deck-tracker-ubuntu.sh`
1. Follow the app instructions.
1. Enjoy!

## How does it works
### The short way
Generates the Marvel Snap Tracke's native binary for Ubuntu, so it can be executed as a regular application. 

### The long way
1. The binary build operation will run isolated from the local computer, this allows mantaining the local computer clean from unnnecessary tools (or just necessary for this build opperation) and also avoiding conflicts with already installed apps. All the opperations will be performed into a container running an Ubuntu 22.04 instance so LXC/LXD will be installed and setup (if it has'nt been done yet).
1. Within the container, the following opperations will be performed:
    1. Installs or updates all the needed tools and dependencies.
    1. Clones or updates the Marvel Snap Tracker's repository by Razviar.
    1. Setups the electron environment in order to build the binary.
    1. Builds the binary, so a native Ubuntu's app is created.
1. Finally, it copies the app binary from the container to the local computer.
1. The container will not be destroyed in order to boost-up further executions (like updates).
1. Requests the user in order to install the app localy generating also a desktop shorcut (available within the Ubuntu's app list).

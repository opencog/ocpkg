#!/usr/bin/env bash
#
#Script is designed to interactively install opencog dependencies on a clean Debian Jessie environment.
#Last Edit 5/28/2016 by Noah Bliss. Major edit. Script is now part of a pair.
#This script installs the dependencies necessary to build OpenCog on Debian.
#Removed cogutil/atomspace build/install. They are now handled by debian-automated-install.sh
# If you encounter an issue don't hesitate to supply a patch on github.

# We can handle our own errors.

# Environment Variables
SELF_NAME=$(basename $0)

# Some tools
PACKAGES_TOOLS="
		git \
		python-pip \
		wget \
		sudo \
		"

# Packages for building opencog
PACKAGES_BUILD="
		build-essential \
		cmake \
		cxxtest \
		rlwrap \
		guile-2.0-dev \
		libiberty-dev \
		libicu-dev \
		libbz2-dev \
		cython \
		python-dev \
		python-zmq \
		python-simplejson \
		libboost-date-time-dev \
		libboost-filesystem-dev \
		libboost-math-dev \
		libboost-program-options-dev \
		libboost-regex-dev \
		libboost-serialization-dev \
		libboost-thread-dev \
		libboost-system-dev \
		libjson-spirit-dev \
		libzmq3-dev \
		libtbb-dev \
		binutils-dev \
		unixodbc-dev \
		uuid-dev \
		libprotoc-dev \
		protobuf-compiler \
		libsdl-gfx1.2-dev \
		libssl-dev \
		tcl-dev \
		tcsh \
		libfreetype6-dev \
		libatlas-base-dev \
		gfortran \
		"

# Packages required for integrating opencog with other services
PACKAGES_RUNTIME="
		unixodbc \
		odbc-postgresql \
		postgresql-client \
		"

# Template for messages printed.
message() {
echo -e "\e[1;34m[$SELF_NAME] $MESSAGE\e[0m"
}

# Install cogutils
install_cogutil(){
MESSAGE="Installing cogutils...." ; message
cd /tmp/
# cleaning up remnants from previous install failures, if any.
rm -rf master.tar.gz cogutils-master/
wget https://github.com/opencog/cogutils/archive/master.tar.gz
tar -xvf master.tar.gz
cd cogutils-master/
mkdir build
cd build/
cmake ..
make -j$(nproc)
sudo make install
cd ../..
rm -rf master.tar.gz cogutils-master/
}

# Install Python Packages
install_python_packages(){
MESSAGE="Installing python packages...." ; message
cd /tmp
# cleaning up remnants from previous install failures, if any.
rm requirements.txt
#Fix for sslv3 Debian error
sudo easy_install --upgrade pip
wget https://raw.githubusercontent.com/opencog/opencog/master/opencog/python/requirements.txt
sudo pip install -U -r /tmp/requirements.txt
rm requirements.txt
}

# Install AtomSpace
install_atomspace(){
MESSAGE="Installing atomspace...." ; message
cd /tmp/
# cleaning up remnants from previous install failures, if any.
rm -rf master.tar.gz atomspace-master/
wget https://github.com/opencog/atomspace/archive/master.tar.gz
tar -xvf master.tar.gz
cd atomspace-master/
mkdir build
cd build/
cmake ..
make -j$(nproc)
sudo make install
cd ../..
rm -rf master.tar.gz atomspace-master/
}

# Function for installing all required dependenceis for building OpenCog,
# as well as dependencies required for running opencog with other services.
install_dependencies() {
MESSAGE="Updating Package db...." ; message
apt-get update

MESSAGE="Installing OpenCog build dependencies...." ; message
if ! (apt-get -y install $PACKAGES_BUILD $PACKAGES_RUNTIME $PACKAGES_TOOLS); then
  MESSAGE="Error installing some of the dependencies... :( :("  ; message
  exit 1
fi
#install_python_packages
#install_cogutil
#install_atomspace
}

# Main Program
install_dependencies
install_python_packages

printf '\n \n'
echo "Dependencies installed, we can clone OpenCog, Atomspace, etc to the current directory if you like."
read -p "Download Opencog source to current path? (y/n) " gitclone
if [ "$gitclone" == "y" ] || [ "$gitclone" == "Y" ]
then
	git clone https://github.com/opencog/opencog.git
	git clone https://github.com/opencog/atomspace.git
	git clone https://github.com/opencog/cogutils.git
else
	echo "Download of OpenCog aborted."
	exit
fi

echo "You should now be able to build according to the OpenCog for noobs instructions. Good luck!"

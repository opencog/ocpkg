#!/usr/bin/env bash
#
#Script is designed to interactively install opencog dependencies on a clean Debian Jessie environment.
#Last Edit 5/28/2016 by Noah Bliss. Major edit. Script is now part of a pair.
#Removed cogutil/atomspace build/install. They are now handled by opencog-installer.sh
# If I break. Fix me on github!

#Prompt for root since we are installing stuff.
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"

# DEFINE PACKAGES TO INSTALL:

# General System Utilities
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

#Install the Deps.
apt-get update
if ! (apt-get install -y $PACKAGES_TOOLS $PACKAGES_BUILD $PACKAGES_RUNTIME)
then
	echo "Installing packages from the Debian repo failed. It's probably your internet, apt sources.list, or we devs need to update a package name."
	exit 1
fi	
#Install the Python Deps.
cd /tmp
rm requirements.txt
#Fix for sslv3 Debian error
sudo easy_install --upgrade pip
wget https://raw.githubusercontent.com/opencog/opencog/master/opencog/python/requirements.txt
sudo pip install -U -r /tmp/requirements.txt
rm requirements.txt

printf '\n \n'
echo "Prerequisite software installed. We should have everything we need to build OpenCog."

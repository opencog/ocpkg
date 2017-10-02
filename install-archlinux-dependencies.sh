#!/bin/bash
#
# This script is used for installing the dependencies required for
# building opencog on archlinux.The script has been tested using docker
# image pritunl/archlinux.
# It is provided for those on 32-bit system or don't want to use
# If you encounter an issue don't hesitate to supply a patch on github.
# TODO :  Add function for installing haskell dependencies.
# trap errors
set -e

# Environment Variables
SELF_NAME=$(basename $0)

PACKAGES_TOOLS="
 		git \
		python-pip \
		wget \
		sudo \
		pkg-config \
		"

# Packages for building opencog
PACKAGES_BUILD="
		gcc \
		make \
		cmake \
		cxxtest \
		rlwrap \
		guile \
		icu
		bzip2 \
		cython \
		python2 \
		python2-pyzmq \
		python2-simplejson \
		boost \
        zeromq \
        intel-tbb \
        binutils \
        gsl \
        unixodbc \
        protobuf \
        protobuf-c \
		sdl_gfx \
		openssl \
		tcl \
		tcsh \
		freetype2 \
		blas \
		lapack \
		gcc-fortran \
		"

PACKAGES_RUNTIME="
		unixodbc \
		psqlodbc \
		libpqxx \
		"

# Template for messages printed.
message() {
echo -e "\e[1;34m[$SELF_NAME] $MESSAGE\e[0m"
}

# Install  json-spirit (4.05)
install_json_spirit(){
MESSAGE="Installing json-spirit library...." ; message
cd /tmp
# cleaning up remnants from previous install failures, if any.
rm -rf json-spirit_4.05.orig.tar.gz json_spirit_v4_05
export BOOST_ROOT=/usr/include/boost/
wget http://http.debian.net/debian/pool/main/j/json-spirit/json-spirit_4.05.orig.tar.gz
tar -xvf json-spirit_4.05.orig.tar.gz
cd json_spirit_v4_05
mkdir build
cd build/
cmake ..
make -j$(nproc)
sudo make install
cd ../..
rm -rf json-spirit_4.05.orig.tar.gz json_spirit_v4_05
}

# Install cogutil
install_cogutil(){
MESSAGE="Installing cogutil...." ; message
cd /tmp/
# cleaning up remnants from previous install failures, if any.
rm -rf master.tar.gz cogutil-master/
wget https://github.com/opencog/cogutil/archive/master.tar.gz
tar -xvf master.tar.gz
cd cogutil-master/
mkdir build
cd build/
cmake ..
make -j"$(nproc)"
sudo make install
cd ../..
rm -rf master.tar.gz cogutil-master/
}

# Install Python Packages
install_opencog_python_packages(){
MESSAGE="Installing python packages...." ; message
cd /tmp
# cleaning up remnants from previous install failures, if any.
rm requirements.txt
wget https://raw.githubusercontent.com/opencog/opencog/master/opencog/python/requirements.txt
sudo pip install -v -U -r /tmp/requirements.txt
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
MESSAGE="Installing OpenCog build dependencies...." ; message
if !  pacman -S --noconfirm $PACKAGES_BUILD $PACKAGES_RUNTIME $PACKAGES_TOOLS; then
  MESSAGE="Error installing some of dependencies... :( :("  ; message
  exit 1
fi

install_json_spirit
}

# Install Link-Grammar
install_link_grammar(){
MESSAGE="Installing Link-Grammar...." ; message
cd /tmp/
# cleaning up remnants from previous install failures, if any.
rm -rf link-grammar-5.*/
wget -r --no-parent -nH --cut-dirs=2 http://www.abisource.com/downloads/link-grammar/current/
tar -zxf current/link-grammar-5*.tar.gz
rm -r current
cd link-grammar-5.*/
mkdir build
cd build
../configure
make -j"$(nproc)"
sudo make install
sudo ldconfig
cd /tmp/
rm -rf link-grammar-5.*/
cd $CURRENT_DIR
}

usage() {
echo "Usage: $SELF_NAME OPTION"
echo " -d Install base/system build dependencies"
echo " -p Install opencog python build dependencies"
echo " -c Install Cogutil"
echo " -a Install Atomspace"
echo " -l Install Link Grammar"
echo " -h This help message"
}

# Main Program
if [ $# -eq 0 ] ; then NO_ARGS=true ; fi

while getopts "dpcalsh" flag ; do
    case $flag in
      d)    INSTALL_DEPENDENCIES=true ;; #base development packages
      p)    INSTALL_OPENCOG_PYTHON_PACKAGES=true ;;
      c)    INSTALL_COGUTIL=true ;;
      a)    INSTALL_ATOMSPACE=true ;;
      l)    INSTALL_LINK_GRAMMAR=true ;;
      h)    usage ;;
      \?)    usage ;;
      *)  UNKNOWN_FLAGS=true ;;
    esac
done

if [ $INSTALL_DEPENDENCIES ] ; then install_dependencies ; fi
if [ $INSTALL_OPENCOG_PYTHON_PACKAGES ] ; then
    install_opencog_python_packages
fi
if [ $INSTALL_COGUTIL ] ; then install_cogutil ; fi
if [ $INSTALL_ATOMSPACE ] ; then install_atomspace ; fi
if [ $INSTALL_LINK_GRAMMAR ] ; then install_link_grammar ; fi
if [ $UNKNOWN_FLAGS ] ; then usage ; fi
if [ $NO_ARGS ] ; then usage ; fi

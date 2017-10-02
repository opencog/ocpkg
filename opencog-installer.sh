#!/usr/bin/env bash
#
#A streamlined and interactive method for installing OpenCog in Linux. 
#This script installs dependencies, downloads OpenCog from Github, compiles and installs it, or if unable to do so, hands-off to the proper program to accomplish those steps.
#Last editor: Noah Bliss
#Last updated on: 5/29/2016
#A few variables quick...
gauthor=opencog
rtdr=ocpkg
branch=master

#Let's start by cleaning off our desk...
clear

echo "

Welcome to the OpenCog installer! 

This program is designed to help you install OpenCog on your system. 
For additional info or help, please check GitHub.

What Linux Distribution are you on? 
*Additional options if Debian is selected.

"
until [ "$vdist" == "1" ]
do
read -p "I am running... [ubuntu|debian|fedora|arch|opensuse]: " dist
  #Enumerate valid choices.
  if [[ "$dist" == @(ubuntu|debian|fedora|arch|opensuse) ]]
  then
    #Choice is valid.
    vdist=1
  else
    echo "Try Again."
  fi
done

#Here we evaluate what distro is running. We either hand-off or process any unique prerequisites that distro has.

#ubuntu
if [ "$dist" == "ubuntu" ]
then
  wget https://raw.githubusercontent.com/opencog/ocpkg/master/ocpkg && chmod 755 ./ocpkg
  echo "Downloaded ockpg. Run it with ./ocpkg"
  #Since we aren't installing for Ubuntu via this script, we exit here.
  exit 0
#debian
elif [ "$dist" == "debian" ]
then
  echo > /dev/null
  #Nothing weird for Debian. We will continue to the universal install menu.
elif [ "$dist" == "fedora" ]
then
  wget https://raw.githubusercontent.com/opencog/ocpkg/master/install-fedora-dependencies.sh && chmod 755 ./install-fedora-dependencies.sh
  echo "Downloaded install-fedora-dependencies.sh. Run it with ./install-fedora-dependencies.sh"
  #Since we aren't installing for Fedora via this script, we exit here. (This would be easy to implement though if Debian testing goes well.)
  exit 0
elif [ "$dist" == "arch" ]
then
  wget https://raw.githubusercontent.com/opencog/ocpkg/master/install-archlinux-dependencies.sh && chmod 755 ./install-archlinux-dependencies.sh
  echo "Downloaded install-archlinux-dependencies.sh. Run it with ./install-archlinux-dependencies.sh"
  #Since we aren't installing for Arch via this script, we exit here.
  exit 0
elif [ "$dist" == "opensuse" ]
then
  wget https://raw.githubusercontent.com/opencog/ocpkg/master/install-opensuse-dependencies.sh && chmod 755 ./install-opensuse-dependencies.sh
  echo "Downloaded install-opensuse-dependencies.sh. Run it with ./install-opensuse-dependencies.sh"
  #Since we aren't installing for openSUSE via this script, we exit here.
  exit 0
fi

#Clean the screen
clear

#Universal Install menu.
echo "

Choose an option below.
Items marked with an X are still in development.

#1.) Just install dependencies. 
#2.) Dependencies, then install OpenCog. (AmeBel method)
#3.) Dependencies, then install OpenCog. (L3vi47h4N method - WIP)
#X.) Dependencies, OpenCog with MOSES. **not yet implemented

"
until [ "$vchoice" == "1" ]
do
read -p "I choose door number... " choice
  if [[ "$choice" == @(1|2|3) ]]
  then
    vchoice=1
  else
    echo "Try Again."
  fi
done

#Just the dependencies.
if [ "$choice" == "1" ]
then
  #Fetch the dependency script using the dist variable as part of the path.
  wget https://raw.githubusercontent.com/"$gauthor"/"$rtdr"/"$branch"/"$dist"/install-"$dist"-dependencies.sh && chmod 755 ./install-"$dist"-dependencies.sh && sudo ./install-"$dist"-dependencies.sh && rm install-"$dist"-dependencies.sh
  exit 0
#Dependencies, then install OpenCog. (AmeBel method)
elif [ "$choice" == "2" ]
then
  #Fetch the dependency script using the dist variable as part of the path.
  wget https://raw.githubusercontent.com/"$gauthor"/"$rtdr"/"$branch"/"$dist"/install-"$dist"-dependencies.sh && chmod 755 ./install-"$dist"-dependencies.sh && sudo ./install-"$dist"-dependencies.sh && rm install-"$dist"-dependencies.sh
  read -p "Do not continue if there were errors in fetching the dependencies. Press [ENTER] to continue..."
  #I need to put a menu-driven selection program here which prompts for which elements of OpenCog a user wants.
  read -p "Install Cogutil? (y/n) " cogutil
  read -p "Install AtomSpace? (y/n) " atomspace
  read -p "UNTESTED: Install LinkGrammar? (y/n) " linkgram
  #read -p "UNTESTED: Install Haskell (may error if run as root)? (y/n) " haskell
  
  #COGUTIL
  if [ "$cogutil" == "y" ] || [ "$cogutil" == "Y" ]
  then
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
  fi
  if [ "$atomspace" == "y" ] || [ "$atomspace" == "Y" ]
  then
    cd /tmp/
   # cleaning up remnants from previous install failures, if any.
   rm -rf master.tar.gz atomspace-master/
  wget https://github.com/opencog/atomspace/archive/master.tar.gz
  tar -xvf master.tar.gz
  cd atomspace-master/
  mkdir build
  cd build/
  cmake ..
  make -j"$(nproc)"
  sudo make install
  cd ../..
  rm -rf master.tar.gz atomspace-master/
  fi
  if [ "$linkgram" == "y" ] || [ "$linkgram" == "Y" ]
  then
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
  fi
  #if [ "$haskell" == "y" ] || [ "$haskell" == "Y" ]
  #then

#Dependencies, then install OpenCog. (L3vi47h4N method)
elif [ "$choice" == "3" ]
then
  #Fetch the dependency script using the dist variable as part of the path.
  wget https://raw.githubusercontent.com/"$gauthor"/"$rtdr"/"$branch"/"$dist"/install-"$dist"-dependencies.sh && chmod 755 ./install-"$dist"-dependencies.sh && sudo ./install-"$dist"-dependencies.sh && rm install-"$dist"-dependencies.sh
    read -p "Do not continue if there were errors in fetching the dependencies. Press [ENTER] to continue..."
        echo "This is still in development. Pressing enter will use git pull to download opencog/atomspace/cogutil to current directory."
        read -p "Download Opencog source to current path? (y/n) " gitclone
        if [ "$gitclone" == "y" ] || [ "$gitclone" == "Y" ]
        then
          git clone https://github.com/opencog/opencog.git
          git clone https://github.com/opencog/atomspace.git
          git clone https://github.com/opencog/cogutil.git
          echo "You should now be able to build according to the OpenCog for noobs instructions. Good luck!"
        else
            echo "Download of OpenCog aborted."
            exit
        fi
elif [ "$choice" == "4" ]
then
        echo "You broke the code if you can read this."
fi

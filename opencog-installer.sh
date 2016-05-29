#!/usr/bin/env bash
#
#Designed for Debian Jessie, compatible with others.
#This script either installs dependencies, downloads OpenCog from Github, compiles and installs it, and leaves the build environment or hands off to the proper program to accomplish those steps.
#Last editor: Noah Bliss
#Last updated on: 5/29/2016

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
  source <(wget -qO- "https://raw.githubusercontent.com/opencog/ocpkg/master/debian/install-debian-dependencies.sh")
  exit 0
#Dependencies, then install OpenCog. (AmeBel method)
elif [ "$choice" == "2" ]
then
        echo > /dev/null
#Dependencies, then install OpenCog. (L3vi47h4N method)
elif [ "$choice" == "3" ]
then
        echo "This is still in development. Pressing enter will use git pull to download opencog/atomspace/cogutils to current directory."
        read -p "Download Opencog source to current path? (y/n) " gitclone
        if [ "$gitclone" == "y" ] || [ "$gitclone" == "Y" ]
        then
          git clone https://github.com/opencog/opencog.git
          git clone https://github.com/opencog/atomspace.git
          git clone https://github.com/opencog/cogutils.git
          echo "You should now be able to build according to the OpenCog for noobs instructions. Good luck!"
        else
            echo "Download of OpenCog aborted."
            exit
        fi
elif [ "$choice" == "4" ]
then
        echo "You broke the code if you can read this."
fi
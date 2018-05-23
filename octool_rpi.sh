#/bin/bash
#
## @file        octool_rpi
## @author      Dagim Sisay <dagiopia@gmail.com>
## @licence     AGPL

#Octool for Raspbian

#CONSTANTS

set -e

GOOD_COLOR='\033[32m'  #GREEN
OKAY_COLOR='\033[33m'  #YELLOW
BAD_COLOR='\033[31m'   #RED
NORMAL_COLOR='\033[0m'

INSTALL_PACKAGES="
	build-essential \
	autoconf-archive \
	autogen \
	libtool \
	bison \
	flex \
	cmake \
	rlwrap \
	libiberty-dev \
	libicu-dev \
	libbz2-dev \
	cython \
	python3-dev \
	python3-simplejson \
	libjson-spirit-dev \
	binutils-dev \
	unixodbc-dev \
	libpq-dev \
	uuid-dev \
	libprotoc-dev \
	protobuf-compiler \
	libssl-dev \
	tcl-dev \
	tcsh \
	libfreetype6-dev \
	libatlas-base-dev \
	gfortran \
	gearman \
	libgearman-dev \
	ccache \
	libgsasl7 \
	libldap2-dev \
	krb5-multidev \
	libatomic-ops-dev \
	libunistring-dev \
	libffi-dev \
	libreadline-dev \
	liboctomap-dev 
	"

INSTALL_RELEX_DEPS="
	swig \
	zlib1g-dev \
	wordnet-dev \
	wordnet-sense-index \
	libatomic-ops-dev \
	libgmp-dev \
	libffi-dev \
	oracle-java8-jdk \
	ant \
	libcommons-logging-java \
	libgetopt-java "




INSTALL_CC_PACKAGES=" python chrpath "


SELF_NAME=$(basename $0)
TOOL_NAME=octool_rpi

export DISTRO_RELEASE=$(lsb_release --codename | awk {' print $2 '})
export DISTRO_JESSIE="jessie"
export DISTRO_STRETCH="stretch"

export CC_TC_DIR_NAME="RPI_OC_TC" #RPI Opencog Toolchain Container
export CC_TC_ROOT="$HOME/$CC_TC_DIR_NAME"
export CC_TC_SRC_DIR="$CC_TC_ROOT/opencog"
export CC_TC_DIR="$CC_TC_ROOT/opencog_rpi_toolchain"
export CC_TC_LIBS_PATH_1="$CC_TC_DIR/opencog_rasp"
export CC_TC_LIBS_PATH_2="$CC_TC_DIR/tools-master/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/arm-linux-gnueabihf/sysroot"

export CC_TC_BOOST_1_55_LIBS="$CC_TC_LIBS_PATH_2/opt/boost_1.55_armhf"
export CC_TC_BOOST_1_62_LIBS="$CC_TC_LIBS_PATH_2/opt/boost_1.62_armhf"

export DPKG__V="1.0-1"

if [ $(uname -m) == "armv7l" ] ; then
	if [ $DISTRO_RELEASE == $DISTRO_JESSIE ] ; then
		printf "${OKAY_COLOR}Version Jessie ${NORMAL_COLOR}\n"
		export DEB_PKG_NAME="opencog-dev_1.0-1_armhf"
	elif [ $DISTRO_RELEASE == $DISTRO_STRETCH ] ; then
		printf "${OKAY_COLOR}Version Stretch ${NORMAL_COLOR}\n"
		export DEB_PKG_NAME="opencog-dev_1.0-2_armhf"
	else
		printf "${OKAY_COLOR}Version Unanticipated :) going with jessie ${NORMAL_COLOR}\n"
		export DEB_PKG_NAME="opencog-dev_1.0-1_armhf"
	fi
fi

BDWGC_DEB="bdwgc-7.6.4-1_armhf.deb" # http://144.76.153.5/opencog/bdwgc-7.6.4-1_armhf.deb
GUILE_DEB="guile-2.2.3-1_armhf.deb" # http://144.76.153.5/opencog/guile-2.2.3-1_armhf.deb
GUILE_V="2.2.3" # https://ftp.gnu.org/gnu/guile/guile-2.2.3.tar.xz
TBB_V="2017_U7" # https://github.com/01org/tbb/archive/2017_U7.tar.gz
LG_V="5.4.3"    # https://github.com/opencog/link-grammar/archive/link-grammar-5.4.3.tar.gz
RELEX_V="1.6.3" # https://github.com/Dagiopia/relex/archive/1.6.3.tar.gz
BDWGC_V="7.6.4" # https://github.com/ivmai/bdwgc/archive/v7.6.4.tar.gz

usage() {
  echo "Usage: $SELF_NAME OPTION"
  echo "Tool for installing necessary packages and preparing environment"
  echo "for OpenCog on a Raspberry PI computer running Raspbian OS."
  echo "  -d   Install base/system dependancies."
  echo "  -o   Install OpenCog (precompilled: may be outdated)"
  echo "  -t   Download and Install Cross-Compilling Toolchain"
  echo "  -c   Cross Compile OpenCog (Run on PC!)"
  echo "  -s   Cross Compile for Raspbian Stretch (boost 1.62)"
  echo "  -v   Verbose output"
  echo -e "  -h   This help message\n"
  exit
}


download_install_oc () {
	wget 144.76.153.5/opencog/$DEB_PKG_NAME.deb
	sudo dpkg -i $DEB_PKG_NAME.deb
	rm $DEB_PKG_NAME.deb
}


setup_sys_for_cc () {
    #downloading cogutil, atomspace and opencog source code
    if [ -d $CC_TC_ROOT ] ; then
    	sudo rm -rf $CC_TC_ROOT/*
    fi
    mkdir -p $CC_TC_SRC_DIR
    cd $CC_TC_SRC_DIR
    rm -rf  *
    wget https://github.com/opencog/cogutil/archive/master.tar.gz
    tar $VERBOSE -xf master.tar.gz
    rm master.tar.gz
    wget https://github.com/opencog/atomspace/archive/master.tar.gz
    tar $VERBOSE -xf master.tar.gz
    rm master.tar.gz
    wget https://github.com/opencog/opencog/archive/master.tar.gz
    tar $VERBOSE -xf master.tar.gz
    rm master.tar.gz
    for d in * ; do echo $d ; mkdir $d/build_hf ; done
    cd $CC_TC_ROOT
    #downloading compiler and libraries
    wget https://github.com/opencog/opencog_rpi/archive/master.tar.gz
    tar $VERBOSE -xf master.tar.gz
    mv opencog_rpi-master opencog_rpi_toolchain
    mv $CC_TC_DIR/arm_gnueabihf_toolchain.cmake $CC_TC_SRC_DIR
    rm master.tar.gz 
}


do_cc_for_rpi () {
    if [ -d $CC_TC_ROOT -a -d $CC_TC_DIR -a -d $CC_TC_SRC_DIR ] ; then
		printf "${GOOD_COLOR}Everything seems to be in order.${NORMAL_COLOR}\n"
    else

		printf "${BAD_COLOR}You do not seem to have the compiler toolchain.\n \
			Please run:\n\t\t$SELF_NAME -tc \n${NORMAL_COLOR}\n"
		exit
    fi
    
    if [ $FOR_STRETCH ] ; then 
    	printf "${OKAY_COLOR}Compiling with Boost 1.62${NORMAL_COLOR}\n"
	tar -xf $CC_TC_BOOST_1_62_LIBS.tar.gz -C $CC_TC_LIBS_PATH_2/opt
	cp -Prf $VERBOSE $CC_TC_BOOST_1_62_LIBS/include/boost $CC_TC_LIBS_PATH_2/usr/include
	cp -Prf $VERBOSE $CC_TC_BOOST_1_62_LIBS/lib/arm-linux-gnueabihf/* $CC_TC_LIBS_PATH_2/usr/lib
	# boost 1.62 needs stdc++ 6.0.22
	cd $CC_TC_LIBS_PATH_2/../lib
	ln -sf $CC_TC_LIBS_PATH_2/opt/libstdc++.so.6.0.22 libstdc++.so.6
	export DEB_PKG_NAME="opencog-dev_1.0-2_armhf"
	export DPKG__V="1.0-2"
    else
    	printf "${OKAY_COLOR}Compiling with Boost 1.55${NORMAL_COLOR}\n"
	tar -xf $CC_TC_BOOST_1_55_LIBS.tar.gz -C $CC_TC_LIBS_PATH_2/opt
	cp -Prf $VERBOSE $CC_TC_BOOST_1_55_LIBS/include/boost $CC_TC_LIBS_PATH_2/usr/include
	cp -Prf $VERBOSE $CC_TC_BOOST_1_55_LIBS/lib/arm-linux-gnueabihf/* $CC_TC_LIBS_PATH_2/usr/lib
	# boost 1.55 needs stdc++ 6.0.20
	cd $CC_TC_LIBS_PATH_2/../lib
	ln -sf $CC_TC_LIBS_PATH_2/opt/libstdc++.so.6.0.20 libstdc++.so.6
	export DEB_PKG_NAME="opencog-dev_1.0-1_armhf"
    fi

    export PATH=$PATH:$CC_TC_DIR/tools-master/arm-bcm2708/arm-rpi-4.9.3-linux-gnueabihf/bin
    
    cp -f $CC_TC_DIR/cmake/* $CC_TC_SRC_DIR/opencog-master/lib
    
    #compiling cogutil
    cd $CC_TC_SRC_DIR/cogutil-master/build_hf
    rm -rf $CC_TC_SRC_DIR/cogutil-master/build_hf/*
    cmake -DCMAKE_TOOLCHAIN_FILE=$CC_TC_SRC_DIR/arm_gnueabihf_toolchain.cmake -DCMAKE_INSTALL_PREFIX=$CC_TC_LIBS_PATH_1/usr/local -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc)
    make install

    #compiling atomspace
    cd $CC_TC_SRC_DIR/atomspace-master/build_hf
    rm -rf $CC_TC_SRC_DIR/atomspace-master/build_hf/*

    #till we can cross compile with stack
    rm -f $CC_TC_SRC_DIR/atomspace-master/lib/FindStack.cmake

    cmake -DCMAKE_TOOLCHAIN_FILE=$CC_TC_SRC_DIR/arm_gnueabihf_toolchain.cmake -DCMAKE_INSTALL_PREFIX=$CC_TC_LIBS_PATH_1/usr/local -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc)
    make install

    #compiling opencog
    cd $CC_TC_SRC_DIR/opencog-master/build_hf
    rm -rf $CC_TC_SRC_DIR/opencog-master/build_hf/*
    cmake -DCMAKE_TOOLCHAIN_FILE=$CC_TC_SRC_DIR/arm_gnueabihf_toolchain.cmake -DCMAKE_INSTALL_PREFIX=$CC_TC_LIBS_PATH_1/usr/local -DCMAKE_BUILD_TYPE=Release ..
    make -j$(nproc)
    make install

    #correct RPATHS
    cd $CC_TC_ROOT
    wget https://raw.githubusercontent.com/Dagiopia/my_helpers/master/batch_chrpath/batch_chrpath.py
    python batch_chrpath.py $CC_TC_LIBS_PATH_1/usr/local $CC_TC_LIBS_PATH_1 $CC_TC_LIBS_PATH_2
    rm batch_chrpath.py

    #package into deb
    cd $CC_TC_DIR
    sudo rm -rf $DEB_PKG_NAME
    cp -ur opencog_rasp $DEB_PKG_NAME
    cd $CC_TC_DIR/$DEB_PKG_NAME
    mkdir ./usr/local/lib/pkgconfig DEBIAN
    echo """Package: opencog-dev
Priority: optional
Section: universe/opencog
Maintainer: Dagim Sisay <dagiopia@gmail.com>
Architecture: armhf
Version: $DPKG__V
Homepage: wiki.opencog.org
Description: Artificial General Inteligence Engine for Linux
  Opencog is a gigantic software that is being built with the ambition
  to one day create human like intelligence that can be conscious and
  emotional.
  This is hopefully the end of task-specific narrow AI.
  This package includes the files necessary for running opencog on RPI3.""" > DEBIAN/control

     echo '''#Manually written pkgconfig file for opencog - START
prefix=/usr/local
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include
Name: opencog
Description: Artificial General Intelligence Software
Version: 1.0
Cflags: -I${includedir}
Libs: -L${libdir}
#Manually written pkgconfig file for opencog - END''' > ./usr/local/lib/pkgconfig/opencog.pc
     cd ..
     sudo chown -R root:staff $DEB_PKG_NAME
     sudo dpkg-deb --build $DEB_PKG_NAME
}


install_guile () {
    # install guile 
    printf "${OKAY_COLOR}Installing Guile from source $GUILE_V ${NORMAL_COLOR}\n"
    cd /tmp
    mkdir $VERBOSE -p /tmp/guile_temp_
    rm $VERBOSE -rf /tmp/guile_temp_/*
    cd /tmp/guile_temp_
    wget https://ftp.gnu.org/gnu/guile/guile-$GUILE_V.tar.xz
    tar $VERBOSE -xf guile-$GUILE_V.tar.xz
    cd guile-$GUILE_V
    ./configure
    make -j2 LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
    sudo make install 
    sudo ldconfig
    cd $HOME
    rm $VERBOSE -rf /tmp/guile_temp_
}

install_guile_deb () {
    printf "${OKAY_COLOR}Installing Guile from deb pkg $GUILE_V ${NORMAL_COLOR}\n"
    wget http://144.76.153.5/opencog/$GUILE_DEB
    sudo dpkg -i $GUILE_DEB
    sudo apt-get -f install 
    rm $GUILE_DEB
}


install_tbb () {
    #download, compile and install TBB
    printf "${OKAY_COLOR}Installing Threading Building Blocks (TBB)${NORMAL_COLOR}\n"
    cd /tmp
    mkdir -p /tmp/tbb_temp_
    rm -rf $VERBOSE /tmp/tbb_temp_/*
    cd /tmp/tbb_temp_
    wget https://github.com/01org/tbb/archive/$TBB_V.tar.gz
    tar $VERBOSE -xf $TBB_V.tar.gz
    cd tbb-$TBB_V
    make tbb CXXFLAGS+="-DTBB_USE_GCC_BUILTINS=1 -D__TBB_64BIT_ATOMICS=0"
    sudo cp $VERBOSE -r include/serial include/tbb /usr/local/include
    sudo cp $VERBOSE build/linux_armv7*_release/libtbb.so.2 /usr/local/lib/
    cd /usr/local/lib
    sudo ln $VERBOSE -sf libtbb.so.2 libtbb.so
    sudo ldconfig
    cd $HOME
    rm $VERBOSE -rf /tmp/tbb_temp_
}

install_lg () {
    #download, compile and instal link-grammar
    printf "${OKAY_COLOR}Installing Link Grammar${NORMAL_COLOR}\n"
    cd /tmp
    mkdir $VERBOSE -p /tmp/lg_temp_
    cd /tmp/lg_temp_
    rm $VERBOSE -rf $HOME/lg_temp_/*
    wget https://github.com/opencog/link-grammar/archive/link-grammar-$LG_V.tar.gz
    tar $VERBOSE -xf link-grammar-$LG_V.tar.gz
    cd link-grammar-link-grammar-$LG_V
    ./autogen.sh
    ./configure
    make -j2
    sudo make install
    cd /usr/lib/
    sudo ln $VERBOSE -sf ../local/lib/liblink-grammar.so.5 liblink-grammar.so.5
    sudo ldconfig
    cd $HOME/
    rm $VERBOSE -rf /tmp/lg_temp_
}

install_relex () {
    #Java wordnet library
    printf "${OKAY_COLOR}Installing Relex${NORMAL_COLOR}\n"
    cd /tmp
    mkdir $VERBOSE -p /tmp/relex_temp_
    cd /tmp/relex_temp_
    rm $VERBOSE -rf /tmp/relex_temp_/*
    wget http://downloads.sourceforge.net/project/jwordnet/jwnl/JWNL%201.4/jwnl14-rc2.zip
    unzip jwnl14-rc2.zip jwnl14-rc2/jwnl.jar
    sudo mv $VERBOSE  jwnl14-rc2/jwnl.jar /usr/local/share/java/
    sudo chmod $VERBOSE  0644 /usr/local/share/java/jwnl.jar
    
    #installing relex
    wget https://github.com/Dagiopia/relex/archive/$RELEX_V.tar.gz
    tar $VERBOSE -xf $RELEX_V.tar.gz 
    cd relex-$RELEX_V
    export CLASSPATH=/usr/local/share/java
    ant build
    sudo ant install
    cd $HOME
    rm $VERBOSE -rf /tmp/relex_temp_
}

install_bdwgc_deb () {
    printf "${OKAY_COLOR}Installing bdwgc from deb pkg${NORMAL_COLOR}\n"
    wget http://144.76.153.5/opencog/$BDWGC_DEB
    sudo dpkg -i $BDWGC_DEB
    sudo apt-get -f install 
    rm $BDWGC_DEB
}

install_bdwgc () {
    # install bdwgc garbage collector
    printf "${OKAY_COLOR}Installing bdwgc from source${NORMAL_COLOR}\n"
    cd /tmp
    mkdir $VERBOSE -p /tmp/bdwgc_temp_
    rm -rf /tmp/bdwgc_temp_/*
    cd /tmp/bdwgc_temp_
    wget https://github.com/ivmai/bdwgc/archive/v$BDWGC_V.tar.gz
    tar $VERBOSE -xf v$BDWGC_V.tar.gz
    cd bdwgc-$BDWGC_V
    ./autogen.sh
    ./configure
    make -j2
    sudo make install
    sudo ldconfig
    cd $HOME
    rm $VERBOSE -rf /tmp/bdwgc_temp_
}



if [ $# -eq 0 ] ; then
  printf "${BAD_COLOR}ERROR!! Please specify what to do\n${NORMAL_COLOR}"
  usage
else
  while getopts "drotcsvh:" switch ; do
    case $switch in
      d)    INSTALL_DEPS=true ;;
      o)    INSTALL_OC=true ;;
      t)    SETUP_TC=true ;;
      c)    CC_OPENCOG=true ;;
      s)    FOR_STRETCH=true ;;
      v)    SHOW_VERBOSE=true ;;
      h)    usage ;;
      *)    printf "ERROR!! UNKNOWN ARGUMENT!!\n"; usage ;;
    esac
  done
fi


if [ $SHOW_VERBOSE ] ; then
	printf "${OKAY_COLOR}I will be verbose${NORMAL_COLOR}\n"
	APT_ARGS=" -V "
	VERBOSE=" -v "
else
	APT_ARGS=" -qq "
fi

if [ $INSTALL_DEPS ] ; then
	echo "Install Deps"

	#only allow installation for arm device (RPI)
	if [ $(uname -m) == "armv7l" ] ; then
		printf "${GOOD_COLOR}okay it's an ARM7... \
			Installing packages${NORMAL_COLOR}\n"
	        sudo apt-get install -y $APT_ARGS $INSTALL_PACKAGES
		if [ "$DISTRO_RELEASE" == "$DISTRO_STRETCH" ] ; then
			sudo apt-get install -y $APT_ARGS libboost1.62-dev
		else
			#install boost 1.55
			sudo apt-get install -y $APT_ARGS libboost1.55-all-dev
			#install boost 1.60
			#wget http://144.76.153.5/opencog/libboost-1.55-all-dev-1_armhf.deb
			#sudo dpkg -i libboost-1.55-all-dev-1_armhf.deb
			#rm libboost-1.55-all-dev-1_armhf.deb
		fi
	#	install_bdwgc # install bdwgc from source
	#	install_guile # install guile  from source
		
		install_bdwgc_deb # install bdwgc from deb pkg
		install_guile_deb # install guile from a deb pkg
		install_tbb   # install TBB
		
		sudo apt-get -y install $APT_ARGS $INSTALL_RELEX_DEPS
		sudo update-alternatives --auto java 
		sudo update-alternatives --auto javac
    		export JAVA_HOME=/usr/lib/jvm/jdk-8-oracle-arm32-vfp-hflt
    		export LC_ALL=en_US.UTF8
		install_lg   # install link-grammar
		install_relex # install relex

		printf "${GOOD_COLOR}Done Installing Dependancies!${NORMAL_COLOR}\n"

	else
		printf "${BAD_COLOR}Your Machine is Not ARM7!\n \
			The dependancy installation is for RPI running raspbian only. \
			${NORMAL_COLOR}\n"
		exit
	fi

fi

if [ $INSTALL_OC ] ; then
	printf "${OKAY_COLOR}Get Compiled files from somewhere${NORMAL_COLOR}\n"
        download_install_oc
fi

if [ $SETUP_TC ] ; then
	if [ $(uname -m) == "armv7l" ] ; then
		printf "${BAD_COLOR}Your Machine is ARM! \n \
			Let's Cross Compile on a bigger machine.${NORMAL_COLOR}\n"
		exit
	else
		printf "${GOOD_COLOR}okay it's not an ARM machine... \
			Installing CC packages${NORMAL_COLOR}\n"
		printf "${OKAY_COLOR}Downloading Necessary CC Packages${NORMAL_COLOR}\n"
		#make the appropriate directories and git clone the toolchain
		setup_sys_for_cc
	fi
fi

if [ $CC_OPENCOG ] ; then
	echo "Cross Compile OpenCog"
	#check if not running on an arm7 computer
	if [ $(uname -m) == "armv7l" ] ; then
		printf "${BAD_COLOR}Your Machine is ARM! \n \
			Let's Cross Compile on a bigger machine.${NORMAL_COLOR}\n"
		exit
	else
		printf "${GOOD_COLOR}okay it's not an ARM machine... Installing CC packages${NORMAL_COLOR}\n"
		PROCEED_CC=true
	        sudo apt-get install -y $APT_ARGS $INSTALL_CC_PACKAGES
		do_cc_for_rpi
	fi
fi

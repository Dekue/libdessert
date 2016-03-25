#!/bin/bash

#################################################
# preferences / debug                           #
#################################################
# Remove previously installed files and folders?
RM_FILES=false

# Save a lot of time by disabling this if already installed correctly.
UNZIP_NDK=false


#################################################
# dependencies                                  #
#################################################
# Check if git is installed:
type -P git &>/dev/null || { echo "You need to have \"git\" installed, but it is not.  Aborting."; exit 0; }

# Important configuration variables, check these if something went wrong.
GIT_LIBDESSERT=https://github.com/Dekue/libdessert

# Android API level (eg. android-21 = Android 5.0)
ANDROID_PLATFORM=android-21

# Android-NDK
NDK_LOCATION=http://dl.google.com/android/repository
NDK_FILE=android-ndk-r11b-linux-x86_64.zip

# libpcap
LIBPCAP_LOCATION=https://github.com/the-tcpdump-group/libpcap/archive
LIBPCAP_FILE=libpcap-1.7.4.tar.gz

# uthash
UTHASH_LOCATION=https://github.com/troydhanson/uthash/archive
UTHASH_FILE=v1.9.9.tar.gz

# libcli
GIT_LIBCLI=https://github.com/dparrish/libcli


#################################################
# Path variables depending on archive names and #
# directory names in archive. Check these on an # 
# update of uthash etc.                         #
#################################################
INSTALL_DIR=$1
NDK_DIR=${NDK_FILE%"-linux-x86_64.zip"}
LIBPCAP_DIR=${LIBPCAP_FILE%".tar.gz"}
UTHASH_DIR=${UTHASH_FILE%".tar.gz"}
UTHASH_DIR=${UTHASH_DIR#v}
UTHASH_DIR=uthash-$UTHASH_DIR

if [[ $INSTALL_DIR != --install_dir\=* ]]
then
	echo "USAGE: ./android.sh --install_dir=..."
	exit 0
fi

INSTALL_DIR=${INSTALL_DIR:14}
if [[ ${INSTALL_DIR:0:1} != "/" ]]
then
	echo "--install_dir=... expects an absolute path!"
	exit 0
fi

export DESSERT_LIB=$INSTALL_DIR"/libdessert"

lchr=`expr substr $NDK_LOCATION ${#NDK_LOCATION} 1`
if [ ! "$lchr" == "/" ]
then
	NDK_LOCATION=$NDK_LOCATION"/"
fi

lchr=`expr substr $LIBPCAP_LOCATION ${#LIBPCAP_LOCATION} 1`
if [ ! "$lchr" == "/" ]
then
	LIBPCAP_LOCATION=$LIBPCAP_LOCATION"/"
fi

lchr=`expr substr $UTHASH_LOCATION ${#UTHASH_LOCATION} 1`
if [ ! "$lchr" == "/" ]
then
	UTHASH_LOCATION=$UTHASH_LOCATION"/"
fi


ANDROID_TOOLCHAIN=$INSTALL_DIR"/android-toolchain"
if [ ! -d "$INSTALL_DIR" ]
then
	echo "Installation directory does not exist. Creating it..."
	mkdir -p $INSTALL_DIR
fi

# switch to installation directory
cd $INSTALL_DIR

# cleanup old folders, keep downloaded files
if $RM_FILES
then
	echo "Cleaning up old files (from previous installations)..."
	rm -rf bin libdessert libcli android-ndk-*[^zip] uthash-*[^gz] android-toolchain
fi
rm -rf libcli libpcap-*[^gz]

# create bin subdirectory
echo "Creating bin subdirectory..."
mkdir bin

# fetch ndk from configured location
if [ ! -e "$NDK_FILE" ]
then
	echo "Downloading NDK... (794MB)"
	wget -nc -q $NDK_LOCATION$NDK_FILE
	if [ ! -e "$NDK_FILE" ]
	then
		echo "Failed to download Android NDK. Aborting!"
		exit 0
	fi
fi

# fetch needed files from repository
echo "Checking out current libdessert from repository..."
git clone -q $GIT_LIBDESSERT

# install android-ndk and toolchain
if $UNZIP_NDK
then
	echo "Installing Android NDK..."
	unzip $NDK_FILE &> /dev/null
fi
cd $NDK_DIR"/build/tools"
export ANDROID_NDK_ROOT=$INSTALL_DIR"/"$NDK_DIR
export ANDROID_NDK_HOME=$INSTALL_DIR"/"$NDK_DIR
./make-standalone-toolchain.sh --ndk-dir=$INSTALL_DIR"/"$NDK_DIR --install-dir=$ANDROID_TOOLCHAIN
export ANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN
echo "Android Toolchain dir set to $ANDROID_TOOLCHAIN."
if [ ! -d "$ANDROID_TOOLCHAIN" ]
then
	echo "Failed to install android toolchain. Aborting!"
	exit 0
fi
cd $INSTALL_DIR


# copy android-gcc and android-strip to bin directory
echo "Copying android-gcc wrapper to bin..."
cp libdessert/android/android-* bin

# add bin directory to path
echo "Adding bin directory to path..."
export PATH=$INSTALL_DIR/bin:${PATH}

# installing uthash
if [ ! -e "$UTHASH_FILE" ]
then
	echo "Downloading UTHASH..."
	wget -nc -q $UTHASH_LOCATION$UTHASH_FILE
	if [ ! -e "$UTHASH_FILE" ]
	then
		echo "Failed to download UTHASH. Aborting!"
		exit 0
	fi
fi
echo "Installing UTHASH headers..."
tar xvzf $UTHASH_FILE &> /dev/null
cd $UTHASH_DIR"/src"
cp *.h $INSTALL_DIR"/libdessert/include"
cd $INSTALL_DIR

# setting android-gcc as standard compiler
export CC="android-gcc"

# installing libregex
echo "Installing libregex..."
cd libdessert/android/libregex
make CC=$CC DESTDIR=$INSTALL_DIR PREFIX="/libdessert" clean all install &> build.log
cd $INSTALL_DIR
if [ ! -e "libdessert/android/libregex/libregex.a" ]
then
	echo "Failed to built libregex. See \"libdessert/android/libregex/build.log\"!"
	exit 0
fi

# installing libpthreadex
echo "Installing libpthreadex..."
cd libdessert/android/libpthreadex
make &> build.log #CC="android-gcc"  clean all install &> build.log
cd $INSTALL_DIR
if [ ! -e "libdessert/android/libpthreadex/libpthreadex.a" ]
then
	echo "Failed to build libpthreadex. See \"libdessert/android/libpthreadex/build.log\""
	exit 0
fi

# installing libcli
echo "Downloading and installing libcli..."
git clone $GIT_LIBCLI
if [ ! -d "libcli" ]
then
	echo "Failed to create git repository for libcli. Aborting."
	exit 0
fi
echo "Patching libcli..."
cp libdessert/android/libcli-patch/libcli.patch libcli
cd libcli
patch -s < libcli.patch
rm -f libcli.patch

make CC=$CC CFLAGS="-I$INSTALL_DIR/libdessert/include -I. -DSTDC_HEADERS" LDFLAGS="-shared $INSTALL_DIR/libdessert/lib/libregex.a -Wl,-soname,libcli.so" LIBS="" DESTDIR="$INSTALL_DIR" PREFIX="/libdessert" clean libcli.so install &> build.log
cd $INSTALL_DIR
if [ ! -e "libdessert/lib/libcli.so" ]
then
	echo "Failed to build libcli. See \"libcli/build.log\""
	exit 0
fi

# installing libpcap
echo "Downloading libpcap..."
if [ ! -e "$LIBCAP_FILE" ]
then
	wget -nc -q $LIBPCAP_LOCATION$LIBPCAP_FILE
	if [ ! -e "$LIBPCAP_FILE" ]
	then
		echo "Failed to download libpcap. Aborting!"
		exit 0
	fi
fi
echo "Installing libpcap..."
tar xvzf $LIBPCAP_FILE &> /dev/null
mv libpcap-$LIBPCAP_DIR $LIBPCAP_DIR
cd $LIBPCAP_DIR

./configure CFLAGS="-Dlinux" --prefix=$INSTALL_DIR"/libdessert" --host=arm-none-linux-gnueabi --with-pcap=linux ac_cv_linux_vers=2 ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
make &> build.log
make install
cd $INSTALL_DIR
if [ ! -e "libdessert/lib/libpcap.a" ]
then
	echo "Failed to build libpcap. See \"libpcap/build.log\""
	exit 0
fi
exit 0 ##############################
# building libdessert
echo "Building libdessert..."
cd libdessert
sh autogen.sh
CC="gcc-4.9" #change standard compiler back to gcc


#--enable-android-build: checks pthreadex library - doesn't work right now
./configure CFLAGS="-I$INSTALL_DIR/libdessert/include" LDFLAGS="-L$INSTALL_DIR/libdessert/lib" --host=arm-none-linux --without-net-snmp ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes

##### old FLAGS #####
#CFLAGS="-I$INSTALL_DIR/libdessert/include -I$ANDROID_NDK_HOME/platforms/$ANDROID_PLATFORM/arch-arm/usr/include -D__linux__"
#LDFLAGS="-L$INSTALL_DIR/libdessert/lib -L$ANDROID_NDK_HOME/platforms/$ANDROID_PLATFORM/arch-arm/usr/lib"
#--prefix=$INSTALL_DIR"/libdessert/" --host=arm-none-linux --without-net-snmp --enable-android-build ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
#####################
# setting the CPPFLAGS fixes a flaw in the configure script, where always the standard include "/usr/include" is appended to the compiler flags
make CPPFLAGS="" &> build.log
make install

cd $INSTALL_DIR
if [ ! -e "libdessert/lib/libdessert.a" ]
then
	echo "Failed to build libdessert. See \"libdessert/build.log\"."
	exit 0
fi

# cleanup
echo "Cleaning up..."
#rm *.tar.gz
#rm -rf libcli libcli-patch libdessert libpcap-*[^gz] libpthreadex libregex uthash-*[^gz]
echo "MARK"
exit 0 #####
# Building archive
echo "Building archive..."
tar cvzf libdessert_android.tar.gz libdessert &> /dev/null

echo ""
echo "IMPORTANT: Check if any errors occured! If yes, you first need to manually fix them and restart this script."
echo ""
echo "PRESS A KEY TO CONTINUE..."
read -n 1 -s
echo "The library has been tar'ed to the file libdessert_android.tar.gz."
echo "=================================================================="
echo "As last step you have to set the following environment variables:"
echo "  export ANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN"
echo "  export DESSERT_LIB=$INSTALL_DIR/libdessert"
echo "  export ANDROID_NDK_HOME=$INSTALL_DIR/$NDK_DIR"
echo "  export PATH=\$PATH:$INSTALL_DIR/bin"
echo "=================================================================="
echo "You can now do: make android from any dessert daemon source dir!"


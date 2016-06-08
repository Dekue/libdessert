#!/bin/bash

#################################################
# preferences / debug                           #
#################################################
# remove files before installation (does not include downloaded files)
RM_FILES=true

# Save a lot of time by disabling this if already installed correctly
# and you have to compile numerous times. Will still install if
# essential directories are not present.
RE_INSTALL_NDK=false

# Save additional time by configuring silently.
VERBOSITY=--silent

#################################################
# dependencies                                  #
#################################################
# Check if git is installed:
type -P git &>/dev/null || { echo "You need to have \"git\" installed, but it is not.  Aborting."; exit 0; }

# Important configuration variables, check these if something went wrong.
GIT_LIBDESSERT=https://github.com/Dekue/libdessert
GIT_DAEMONS=https://github.com/Dekue/des-routing-algorithms

# Android API level (eg. android-21 = Android 5.0)
ANDROID_PLATFORM=android-16

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

# zlib-check
GIT_ZLIB_CHECK=https://raw.githubusercontent.com/FFMS/ffms2/master/m4/check_zlib.m4

# iwlib.h stable v29
GIT_IWLIB=https://raw.githubusercontent.com/CyanogenMod/android_external_wireless-tools/master/iwlib.h

#SE policies
GIT_SE_P=https://github.com/xmikos/setools-android.git

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

export DESSERT_LIB=$INSTALL_DIR"/dessert-lib"

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
	rm -rf bin libcli uthash-*[^gz] libpcap-*[^gz] libdessert_android.tar.gz dessert-lib setools-android setools repo dependencies apk_files.* dessert-lib libdessert #des-routing-algorithms
fi
if [ ! -d "$NDK_DIR" ] || [ ! -d "$ANDROID_TOOLCHAIN" ]
then
	RE_INSTALL_NDK=true
fi
if $RE_INSTALL_NDK
then
	rm -rf android-ndk-*[^zip] android-toolchain
fi

# create bin subdirectory
echo "Creating subdirectories..."
mkdir bin
mkdir -p dessert-lib/{include,lib}

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
echo "Cloning libdessert from repository..."
git clone -q $GIT_LIBDESSERT

# install android-ndk and toolchain
if $RE_INSTALL_NDK
then
	echo "Installing Android NDK... (this may take a few minutes)"
	unzip $NDK_FILE &> /dev/null
fi
cd $NDK_DIR"/build/tools"
export ANDROID_NDK_ROOT=$INSTALL_DIR"/"$NDK_DIR
export ANDROID_NDK_HOME=$INSTALL_DIR"/"$NDK_DIR
if $RE_INSTALL_NDK
then
	./make-standalone-toolchain.sh --ndk-dir=$ANDROID_NDK_HOME --install-dir=$ANDROID_TOOLCHAIN
fi
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
mv libdessert/android/android-* bin

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
mv *.h $INSTALL_DIR"/dessert-lib/include"
cd $INSTALL_DIR

# setting android-gcc as standard compiler
export CC="android-gcc"

# installing libregex
echo "Installing libregex..."
cd libdessert/android/libregex
make CC=$CC DESTDIR=$INSTALL_DIR PREFIX="/dessert-lib" clean all install &> build.log
cd $INSTALL_DIR
if [ ! -e "dessert-lib/lib/libregex.a" ]
then
	echo "Failed to built libregex. See \"dessert-lib/libregex/build.log\"!"
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
mv libdessert/android/libcli-patch/libcli.patch libcli
cd libcli
patch -s < libcli.patch
rm -f libcli.patch

make CC=$CC CFLAGS="-I$INSTALL_DIR/dessert-lib/include -I. -DSTDC_HEADERS" LDFLAGS="-shared $INSTALL_DIR/dessert-lib/lib/libregex.a -Wl,-soname,libcli.so" LIBS="" DESTDIR="$INSTALL_DIR" PREFIX="/dessert-lib" clean libcli.so install &> build.log
cd $INSTALL_DIR
if [ ! -e "dessert-lib/lib/libcli.so" ]
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
./configure $VERBOSITY CFLAGS="-Dlinux" --prefix=$INSTALL_DIR"/dessert-lib" --host=arm-none-linux-gnueabi --with-pcap=linux ac_cv_linux_vers=2 ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
make &> build.log
make install
cd $INSTALL_DIR
if [ ! -e "dessert-lib/lib/libpcap.a" ]
then
	echo "Failed to build libpcap. See \"libpcap/build.log\""
	exit 0
fi

# building libdessert
echo "Building libdessert..."
cd libdessert/m4
wget -nc -q $GIT_ZLIB_CHECK
cd ../../dessert-lib/include
wget -nc -q $GIT_IWLIB
cd ../../libdessert
sh autogen.sh
cp $ANDROID_NDK_HOME/platforms/$ANDROID_PLATFORM/arch-arm/usr/include/linux/wireless.h $INSTALL_DIR/dessert-lib/include

./configure $VERBOSITY CFLAGS="-I$INSTALL_DIR/dessert-lib/include -I$ANDROID_NDK_HOME/platforms/$ANDROID_PLATFORM/arch-arm/usr/include -D__linux__" LDFLAGS="-L$INSTALL_DIR/dessert-lib/lib -L$ANDROID_NDK_HOME/platforms/$ANDROID_PLATFORM/arch-arm/usr/lib" --prefix=$INSTALL_DIR"/dessert-lib/" --host=arm-none-linux --without-net-snmp --enable-android-build ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes

# setting the CPPFLAGS fixes a flaw in the configure script, where always the standard include "/usr/include" is appended to the compiler flags
make CPPFLAGS="" &> build.log
make install &> install.log

cd $INSTALL_DIR
if [ ! -e "dessert-lib/lib/libdessert.a" ]
then
	echo "Failed to build libdessert. See \"libdessert/build.log\", \"libdessert/install.log\" or \"libdessert/config.log\"."
	exit 0
fi

# building archive
echo "Building archive..."
tar cvzf libdessert_android.tar.gz dessert-lib &> /dev/null

# installing routing daemons
echo "Downloading and installing routing daemons..."
git clone $GIT_DAEMONS
if [ ! -d "des-routing-algorithms" ]
then
	echo "Failed to create git repository for the daemons. Aborting."
	exit 0
fi
cd des-routing-algorithms/des-batman/trunk
make android
cd ../../des-olsr/trunk
make android
cd ../../des-hello
make
cd ../..
#TODO: make daemons, make dynamic repo *.xml, archive them into APK-files.tar.gz

# installing routing daemons
echo "Downloading and installing SE policy tools..."
git clone $GIT_SE_P
if [ ! -d "setools-android" ]
then
	echo "Failed to create git repository for setools-android. Aborting."
	exit 0
fi
echo "Patching setools..."

#gather files needed for APK
mkdir setools
mv -f libdessert/android/setools-patch/setools.patch setools-android/jni/Application.mk
$ANDROID_NDK_HOME/ndk-build -C setools-android
mv setools-android/libs/armeabi-v7a/sepolicy-inject setools
mv libdessert/android/injector.sh setools

mkdir dependencies
cp dessert-lib/lib/libcli.so dependencies/libcli
cp dessert-lib/lib/libpcap.so dependencies/libpcap
cp dessert-lib/lib/libdessert.so dependencies/libdessert
#TODO: libdessert-extra: ARM-v7a

D_FIL=trunk/android.files
D_ALG=des-routing-algorithms
mkdir repo
mv $D_ALG/des-batman/$D_FIL/des-batman-2.0.zip repo
mv $D_ALG/des-olsr/$D_FIL/des-olsr-2.0.zip repo
mv $D_ALG/des-ara/$D_FIL/des-ara-3.0.zip repo
mv $D_ALG/des-hello/android.files/des-hello-2.0.zip repo

# building archive: files really needed for the android APK: cli, pcap, dessert, setools, daemons
tar cvzf apk_files.tar.gz dependencies setools repo

# cleanup
echo "Cleaning up..."
rm -rf libcli libcli-patch libpcap-* libregex uthash-* setools-android bin dependencies setools dessert-lib repo libdessert #des-routing-algorithms

echo ""
echo "IMPORTANT: Check if any errors occured! If yes, you first need to manually fix them and restart this script."
echo ""
echo "PRESS A KEY TO CONTINUE..."
read -n 1 -s
echo "The files needed for the android manager app are included in apk_files.tar.gz."
echo "The files needed for building own daemons are included in libdessert_android.tar.gz."
echo "=================================================================="
echo "You can compile your own daemons by setting following environment variables:"
echo "  export ANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN"
echo "  export DESSERT_LIB=$INSTALL_DIR/libdessert"
echo "  export ANDROID_NDK_HOME=$INSTALL_DIR/$NDK_DIR"
echo "  export PATH=\$PATH:$INSTALL_DIR/bin"
echo "=================================================================="

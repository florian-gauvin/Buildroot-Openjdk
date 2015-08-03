Here is a full pre-configured Buildroot environment that will create a tar file with Celix and all that Celix need in it.
You just need to run the command "make" in the buildroot directory to launch the build.

If you want to create a Docker Image with this (You need to have docker):
When the build is finished :
Import the built image of celix in docker :
Go to the following directory : buildroot/output/images
Enter the following command : docker import - name < rootfs.tar
You will have a docker image that is fewer than 140MB

Here are the steps that I have followed to have this pre-configured buildroot with a openjdk package :

1. If docker is already installed on your pc go to the next steps, other go to this website : https://docs.docker.com/userguide/, click on the install tab, choose your distribution and follow the steps.

2. In the terminal, go to the directory where you want to have buildroot and and run this command : git clone https://github.com/cranby/rpi-buildroot/ --branch openjdk

3. In rpi-buildroot/package/jamvm/jamvm.mk erase the following line : --without pic \

4. In rpi-buildroot/package/openjdk delete the patch openjdk-no-so-jar

5. In rpi-buildroot/package/openjdk/openjdk.mk :

    a. In order to avoid linking problems with libffi, add the following lines after OPENJDK_PROJECT :
    export LIBBFFI_CFLAGS=-I/$(HOST_DIR)/usr/x86_64-linux-gnu/include
    export LIBBFFI_CFLAGS=-L/$(HOST_DIR)/usr/x86_64-linux-gnu/sysroot/usr/lib/ -lffi

    b. To avoid missing headers of X11, in OPENJDK_CONF_OPT, add the following line :
    --disable-headful
    
    c. In OPENJDK_MAKE_OPT, change "all images pofiles" by "profiles", because we want only the compact profiles of openjdk
    and just after in CONF change "linux-arm-normal-zero-release" by "linux-x86_64-normal-zero-release"
    
    d. In OPENJDK_DEPENDENCIES, add the following dependencies
    libffi cups freetype xlib_libXrender xlib_libXt xlib_libXext xlib_libXtst libusb
    
    e. There is three compact run time environment for openjdk,
    On the following website you can see what are these run time environments and choose which one you need : http://openjdk.java.net/jeps/161
    At the end of the file, in OPENJDK_INSTALL_TARGET_CMDS, add the two following lines replacing the X by the 2 compact profiles that you don't need :
    rm -f -r $(TARGET_DIR)/usr/lib/jvm/j2re-comapctX-image
    rm -f -r $(TARGET_DIR)/usr/lib/jvm/j2re-comapctX-image

6. If you want to use dockerfile to build Celix automatically, In buildroot/package/fakeroot/fakeroot.mk, add the following line :
HOST_FAKEROOT_CONF_OPTS = --with-ipc=tcp

7. In the terminal, in the directory rpi-buildroot, run the following command : make menuconfig

8. Select the following options : (This are the options that I have chosen for the INAETICS project but you can choose others target architecture, c library or target packages but you have to enable openjdk )

    Target options
        Target Architecture : x86_64
        Target Architecture Variant : atom
    Toolchain
        C library : glibc
        Enable C++ support
    Target Packages
        Interpreter languages and scripting
            openjdk : y
        Libraries
            Audio/Sound
                alsa-lib : y

9. Escape and save the changes

10. Launch the build, run the command : make

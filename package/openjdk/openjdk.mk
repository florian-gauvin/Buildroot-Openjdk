################################################################################
#
# openjdk
#
# Please be aware that, when cross-compiling, the OpenJDK configure script will
# generally use 'target' where autoconf traditionally uses 'host'
#
################################################################################

#Version is the same as OpenJDK HG tag
#OPENJDK_VERSION = jdk8u20-b26
#Release is the same as 
#OPENJDK_RELEASE = jdk8u20
#OPENJDK_PROJECT = jdk8u

OPENJDK_VERSION = jdk9-b36
OPENJDK_RELEASE = m2
OPENJDK_PROJECT = jigsaw



export LIBFFI_CFLAGS=-I$(HOST_DIR)/usr/x86_64-buildroot-linux-gnu/include
export LIBFFI_LIBS=-L$(HOST_DIR)/usr/x86_64-buildroot-linux-gnu/sysroot/usr/lib/ -lffi


# TODO make conditional
# --with-import-hotspot=$(STAGING_DIR)/hotspot \

OPENJDK_CONF_OPT = \
	--with-jvm-interpreter=cpp \
	--with-jvm-variants=zero \
	--enable-openjdk-only \
	--with-freetype-include=$(STAGING_DIR)/usr/include/freetype2 \
	--with-freetype-lib=$(STAGING_DIR)/usr/lib \
        --with-freetype=$(STAGING_DIR)/usr/ \
        --with-debug-level=release \
        --openjdk-target=$(GNU_TARGET_NAME) \
	--with-sys-root=$(STAGING_DIR) \
	--with-tools-dir=$(HOST_DIR) \
	--disable-freetype-bundling \
        --enable-unlimited-crypto \
	--disable-headful \
	
	
	

ifeq ($(BR2_OPENJDK_CUSTOM_BOOT_JDK),y)
OPENJDK_CONF_OPT += --with-boot-jdk=$(call qstrip,$(BR2_OPENJDK_CUSTOM_BOOT_JDK_PATH))
endif

OPENJDK_MAKE_OPT = profiles CONF=linux-x86_64-normal-zero-release
OPENJDK_DEPENDENCIES = jamvm alsa-lib host-pkgconf libffi cups freetype xlib_libXrender xlib_libXt xlib_libXext xlib_libXtst libusb 

OPENJDK_LICENSE = GPLv2+ with exception
OPENJDK_LICENSE_FILES = COPYING

ifeq ($(BR2_OPENJDK_CUSTOM_LOCAL),y)

OPENJDK_SITE = $(call qstrip,$(BR2_OPENJDK_CUSTOM_LOCAL_PATH))
OPENJDK_SITE_METHOD = local

else

OPENJDK_DOWNLOAD_SITE = http://hg.openjdk.java.net/$(OPENJDK_PROJECT)/$(OPENJDK_RELEASE)
OPENJDK_SOURCE =
OPENJDK_SITE = $(OPENJDK_DOWNLOAD_SITE)
OPENJDK_SITE_METHOD = wget

# OpenJDK uses a mercurial forest structure
# thankfully the various forests can be downloaded as individual .tar.gz files using
# the following URL structure
# http://hg.openjdk.java.net/$(OPENJDK_PROJECT)/archive/$(OPENJDK_VERSION).tar.bz2
# http://hg.openjdk.java.net/$(OPENJDK_PROJECT)/corba/archive/$(OPENJDK_VERSION).tar.bz2
# ...
OPENJDK_OPENJDK_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_HOTSPOT_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/hotspot/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_CORBA_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/corba/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_JAXP_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/jaxp/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_JAXWS_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/jaxws/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_JDK_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/jdk/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_LANGTOOLS_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/langtools/archive/$(OPENJDK_VERSION).tar.gz
OPENJDK_NASHORN_DOWNLOAD = $(OPENJDK_DOWNLOAD_SITE)/nashorn/archive/$(OPENJDK_VERSION).tar.gz

define OPENJDK_DOWNLOAD_CMDS
	wget -c $(OPENJDK_OPENJDK_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-openjdk-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_HOTSPOT_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-hotspot-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_CORBA_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-corba-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_JAXP_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-jaxp-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_JAXWS_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-jaxws-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_JDK_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-jdk-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_LANGTOOLS_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-langtools-$(OPENJDK_VERSION).tar.gz
	wget -c $(OPENJDK_NASHORN_DOWNLOAD) -O $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-nashorn-$(OPENJDK_VERSION).tar.gz
endef

OPENJDK_PRE_DOWNLOAD_HOOKS += OPENJDK_DOWNLOAD_CMDS

define OPENJDK_EXTRACT_CMDS
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-openjdk-$(OPENJDK_VERSION).tar.gz -C $(@D)
	mv $(@D)/$(OPENJDK_RELEASE)-$(OPENJDK_VERSION)/* $(@D)
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-hotspot-$(OPENJDK_VERSION).tar.gz -C $(@D)
        ln -s $(@D)/hotspot-$(OPENJDK_VERSION) $(@D)/hotspot
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-corba-$(OPENJDK_VERSION).tar.gz -C $(@D)
	ln -s $(@D)/corba-$(OPENJDK_VERSION) $(@D)/corba
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-jaxp-$(OPENJDK_VERSION).tar.gz -C $(@D)
	ln -s $(@D)/jaxp-$(OPENJDK_VERSION) $(@D)/jaxp
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-jaxws-$(OPENJDK_VERSION).tar.gz -C $(@D)
	ln -s $(@D)/jaxws-$(OPENJDK_VERSION) $(@D)/jaxws
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-jdk-$(OPENJDK_VERSION).tar.gz -C $(@D)
	ln -s $(@D)/jdk-$(OPENJDK_VERSION) $(@D)/jdk
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-langtools-$(OPENJDK_VERSION).tar.gz -C $(@D)
	ln -s $(@D)/langtools-$(OPENJDK_VERSION) $(@D)/langtools
	tar zxvf $(BR2_DL_DIR)/openjdk-$(OPENJDK_RELEASE)-nashorn-$(OPENJDK_VERSION).tar.gz -C $(@D)
	ln -s $(@D)/nashorn-$(OPENJDK_VERSION) $(@D)/nashorn
endef

endif 

define OPENJDK_CONFIGURE_CMDS
	mkdir -p $(STAGING_DIR)/hotspot/lib
	touch $(STAGING_DIR)/hotspot/lib/sa-jdi.jar
	mkdir -p $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/server
	cp $(TARGET_DIR)/usr/lib/libjvm.so $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/server
	ln -sf server $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/client
	touch $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/server/Xusage.txt
	ln -sf libjvm.so $(STAGING_DIR)/hotspot/jre/lib/$(OPENJDK_HOTSPOT_ARCH)/client/libjsig.so
	chmod +x $(@D)/configure
	cd $(@D); ./configure $(OPENJDK_CONF_OPT) OBJCOPY=$(TARGET_OBJCOPY) STRIP=$(TARGET_STRIP) CPP_FLAGS=-lstdc++ CXX_FLAGS=-lstdc++ CPP=$(TARGET_CPP) CXX=$(TARGET_CXX) CC=$(TARGET_CC) LD=$(TARGET_CC)
endef

define OPENJDK_BUILD_CMDS
	# LD is using CC because busybox -ld do not support -Xlinker -z hence linking using -gcc instead
	make OBJCOPY=$(TARGET_OBJCOPY) STRIP=$(TARGET_STRIP) BUILD_CC=gcc BUILD_LD=gcc CPP=$(TARGET_CPP) CXX=$(TARGET_CXX) CC=$(TARGET_CC) LD=$(TARGET_CC) -C $(@D) $(OPENJDK_MAKE_OPT)
endef

define OPENJDK_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib/jvm/
	cp -arf $(@D)/build/*/images/j* $(TARGET_DIR)/usr/lib/jvm/
	# By default there is three java run time environment that are built but 
	# we need only one, so we erase the two run time environment that we don't need
	rm -f -r $(TARGET_DIR)/usr/lib/jvm/j2re-compact1-image
	rm -f -r $(TARGET_DIR)/usr/lib/jvm/j2re-compact3-image
endef

#openjdk configure is not based on automake
$(eval $(generic-package))

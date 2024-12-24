################################################################################
#
# dracut
#
################################################################################

DRACUT_VERSION = 059
DRACUT_SITE = $(call github,dracutdevs,dracut,$(DRACUT_VERSION))
DRACUT_LICENSE = GPL-2.0
DRACUT_LICENSE_FILES = COPYING
DRACUT_CPE_ID_VENDOR = dracut_project

# Dracut requires realpath from coreutils
HOST_DRACUT_DEPENDENCIES += \
	host-pkgconf \
	host-kmod \
	host-coreutils \
	host-cpio \
	host-gzip \
	host-util-linux

DRACUT_DEPENDENCIES += \
	host-dracut \
	kmod \
	pkgconf \
	util-linux

DRACUT_MAKE_ENV += \
	CC="$(TARGET_CC)" \
	PKG_CONFIG="$(HOST_PKG_CONFIG_PATH)" \
	dracutsysrootdir=$(TARGET_DIR)

# When using uClibc or musl, there must be "ld-uClibc.so.1" or
# "ld-musl-x.so" symlinks, respectively - else the init process cannot
# start
define HOST_DRACUT_POST_INSTALL_LIBC_LINKS_MODULE
	$(INSTALL) -D -m 0755 package/dracut/merged-usr-module-setup.sh \
		$(HOST_DIR)/lib/dracut/modules.d/0000-merged-usr/module-setup.sh
	$(INSTALL) -D -m 0755 package/dracut/libc-links-module-setup.sh \
		$(HOST_DIR)/lib/dracut/modules.d/05libc-links/module-setup.sh
endef
HOST_DRACUT_POST_INSTALL_HOOKS += HOST_DRACUT_POST_INSTALL_LIBC_LINKS_MODULE

define DRACUT_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_BLK_DEV_INITRD)
	$(call KCONFIG_ENABLE_OPT,CONFIG_DEVTMPFS)
endef

ifeq ($(BR2_PACKAGE_BASH),y)
DRACUT_DEPENDENCIES += \
	bash \
	bash-completion
endif

# gensplash is gentoo specific
define DRACUT_REMOVE_UNEEDED_MODULES
	$(RM) -r $(TARGET_DIR)/usr/lib/dracut/modules.d/50gensplash
endef
DRACUT_TARGET_FINALIZE_HOOKS += DRACUT_REMOVE_UNEEDED_MODULES

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
DRACUT_DEPENDENCIES += systemd
DRACUT_MAKE_ENV += SYSTEMCTL=$(HOST_DIR)/bin/systemctl
DRACUT_CONF_OPTS += --systemdsystemunitdir=/usr/lib/systemd/system
define DRACUT_REMOVE_SYSTEMD_FILES
	# Do not start dracut services normally. Dracut will enable the dracut
	# services during image creation.
	find $(TARGET_DIR)/etc/systemd/system -name "*dracut*.service" -delete
endef
DRACUT_TARGET_FINALIZE_HOOKS += DRACUT_REMOVE_SYSTEMD_FILES
endif

# Install the dracut-install wrapper which exports the proper LD_LIBRARY_PATH
# when called.
define HOST_DRACUT_INSTALL_WRAPPER
	$(INSTALL) -D -m 755 $(DRACUT_PKGDIR)/dracut-install.in \
		$(HOST_DIR)/bin/dracut-install
endef
HOST_DRACUT_POST_INSTALL_HOOKS += HOST_DRACUT_INSTALL_WRAPPER

define HOST_DRACUT_INSTALL_CROSS_LDD
	$(INSTALL) -D -m 755 $(DRACUT_PKGDIR)/cross-ldd $(TARGET_CROSS)ldd
endef
HOST_DRACUT_POST_INSTALL_HOOKS += HOST_DRACUT_INSTALL_CROSS_LDD

ifeq ($(BR2_INIT_BUSYBOX),y)
# Dracut does not support busybox init (systemd init is assumed to work
# out of the box, though). It provides a busybox module, that does not
# use the same paths as buildroot, and is not meant to be used as an init
# system.
# So it is simpler for users to disable the standard 'busybox' module in
# the configuration file, and enable the "busybox-init' module instead.
# Note that setting the script as executable (0755) is not mandatory,
# but this is what dracut does on all its modules, so lets just conform
# to it.
define HOST_DRACUT_POST_INSTALL_BUSYBOX_INIT_MODULE
	$(INSTALL) -D -m 0755 package/dracut/busybox-init-module-setup.sh \
		$(HOST_DIR)/lib/dracut/modules.d/05busybox-init/module-setup.sh
endef
HOST_DRACUT_POST_INSTALL_HOOKS += HOST_DRACUT_POST_INSTALL_BUSYBOX_INIT_MODULE
endif

$(eval $(autotools-package))
$(eval $(host-autotools-package))

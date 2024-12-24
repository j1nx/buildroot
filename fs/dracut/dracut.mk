################################################################################
#
# Build the dracut initramfs image
#
################################################################################

# Dracut requires realpath from coreutils
ROOTFS_DRACUT_DEPENDENCIES += \
	host-dracut \
	host-kmod \
	dracut

ROOTFS_DRACUT_MODULES_INCLUDE = \
	base \
	fs-lib \
	rootfs-block \
	udev-rules

ROOTFS_DRACUT_MODULES_OMIT = \
	lunmask \
	plymouth \
	resume \
	systemd-ldconfig

ROOTFS_DRACUT_TARGET_DIR="$(ROOTFS_DRACUT_DIR)/target
ROOTFS_DRACUT_FS_ENV = \
	prefix="" \
	DESTROOTDIR="$(ROOTFS_DRACUT_TARGET_DIR)" \
	DRACUT_ARCH=$(BR2_ARCH) \
	DRACUT_COMPRESS_BZIP2="$(HOST_DIR)/bin/bzip2" \
	DRACUT_COMPRESS_GZIP="$(HOST_DIR)/bin/gzip" \
	DRACUT_COMPRESS_LZMA="$(HOST_DIR)/bin/lzma" \
	DRACUT_FIRMWARE_PATH="$(ROOTFS_DRACUT_TARGET_DIR)/usr/lib/firmware" \
	DRACUT_INSTALL="$(HOST_DIR)/bin/dracut-install" \
	DRACUT_INSTALL_PATH="$(ROOTFS_DRACUT_TARGET_DIR)/usr/bin:$(ROOTFS_DRACUT_TARGET_DIR)/usr/sbin:$(ROOTFS_DRACUT_TARGET_DIR)/usr/lib" \
	DRACUT_LDCONFIG=/bin/true \
	DRACUT_LDD="$(TARGET_CROSS)ldd --root=$(ROOTFS_DRACUT_TARGET_DIR)/" \
	DRACUT_MODPROBE="$(HOST_DIR)/sbin/modprobe" \
	DRACUT_PATH="/bin /sbin" \
	STRIP_CMD="$(TARGET_CROSS)strip" \
	udevdir="$(ROOTFS_DRACUT_TARGET_DIR)/usr/lib/udev"

ROOTFS_DRACUT_MKFS_CONF_OPTS = \
	--force \
	--fstab \
	--noprefix \
	--sysroot=$(ROOTFS_DRACUT_TARGET_DIR) \
	--tmpdir=$(ROOTFS_DRACUT_DIR)/rootfs.dracut.tmp \
	--verbose

ifeq ($(BR2_ROOTFS_DEVICE_TABLE_SUPPORTS_EXTENDED_ATTRIBUTES),y)
ROOTFS_DRACUT_FS_ENV += DRACUT_NO_XATTR=true
else
ROOTFS_DRACUT_FS_ENV += DRACUT_NO_XATTR=false
endif

ifeq ($(BR2_PACKAGE_BASH),y)
ROOTFS_DRACUT_MODULES_INCLUDE += bash
else
ROOTFS_DRACUT_MODULES_OMIT += bash
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
ROOTFS_DRACUT_MODULES_INCLUDE += dbus-daemon
else
ROOTFS_DRACUT_MODULES_OMIT += dbus-daemon
endif

#ifeq ($(BR2_PACKAGE_E2FSPROGS_FSCK),y)
#ROOTFS_DRACUT_MODULES_INCLUDE += fs-lib
#else
#ROOTFS_DRACUT_MODULES_OMIT += fs-lib
#endif

ifeq ($(BR2_PACKAGE_DBUS_BROKER),y)
ROOTFS_DRACUT_MODULES_INCLUDE += dbus-broker
else
ROOTFS_DRACUT_MODULES_OMIT += dbus-broker
endif

ifeq ($(BR2_PACKAGE_LIBCAP),y)
ROOTFS_DRACUT_MODULES_INCLUDE += caps
else
ROOTFS_DRACUT_MODULES_OMIT += caps
endif

ifeq ($(BR2_PACKAGE_LIBCURL_CURL),y)
ROOTFS_DRACUT_MODULES_INCLUDE += url-lib
else
ROOTFS_DRACUT_MODULES_OMIT += url-lib
endif

ifeq ($(BR2_PACKAGE_BLUEZ5_UTILS),y)
ROOTFS_DRACUT_MODULES_INCLUDE += 62bluetooth
else
ROOTFS_DRACUT_MODULES_OMIT += 62bluetooth
endif

# Dracut typically executes busybox --list to get a list of installed busybox
# applets. Without a qemu wrapper, executing the busybox binary won't work in a
# cross-compiled environment. To avoid using a qemu-wrapper, we manually pass
# the list to Dracut using the busybox.links file that busybox creates when
# compiling.
ifeq ($(BR2_PACKAGE_BUSYBOX)$(BR2_PACKAGE_BUSYBOX_INDIVIDUAL_BINARIES),yy)
ROOTFS_DRACUT_FS_ENV += \
	BUSYBOX_LIST=`sed -r -e s%.*/%%  $(BUSYBOX_DIR)/busybox.links;`
ROOTFS_DRACUT_MODULES_INCLUDE += busybox
else
ROOTFS_DRACUT_MODULES_OMIT += busybox
endif

ifeq ($(BR2_PACKAGE_MKSH),y)
ROOTFS_DRACUT_MODULES_INCLUDE += mksh
else
ROOTFS_DRACUT_MODULES_OMIT += mksh
endif

ifeq ($(BR2_PACKAGE_BTRFS_PROGS),y)
ROOTFS_DRACUT_MODULES_INCLUDE += btrfs
else
ROOTFS_DRACUT_MODULES_OMIT += btrfs
endif

ifeq ($(BR2_PACKAGE_DASH),y)
ROOTFS_DRACUT_MODULES_INCLUDE += dash
else
ROOTFS_DRACUT_MODULES_OMIT += dash
endif

ifeq ($(BR2_PACKAGE_PERL_I18N),y)
ROOTFS_DRACUT_MODULES_INCLUDE += i18n
else
ROOTFS_DRACUT_MODULES_OMIT += i18n
endif

ifeq ($(BR2_PACKAGE_RNG_TOOLS),y)
ROOTFS_DRACUT_MODULES_INCLUDE += rngd
else
ROOTFS_DRACUT_MODULES_OMIT += rngd
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
ROOTFS_DRACUT_MODULES_INCLUDE += securityfs selinux
else
ROOTFS_DRACUT_MODULES_OMIT += securityfs selinux
endif

ifeq ($(BR2_PACKAGE_BASH)$(BR2_PACKAGE_NETWORK_MANAGER)$(BR2_PACKAGE_SYSTEMD),yyy)
ROOTFS_DRACUT_NETWORK_MANAGER_VERSION_SANATIZED=`echo $(NETWORK_MANAGER_VERSION) |cut -d . -f 1`
ROOTFS_DRACUT_HAS_NETWORK=y
ROOTFS_DRACUT_MODULES_INCLUDE += network network-manager
ROOTFS_DRACUT_MODULES_OMIT += network-legacy
ROOTFS_DRACUT_FS_ENV += \
	NM_VERSION=$(ROOTFS_DRACUT_NETWORK_MANAGER_VERSION_SANATIZED)
else ifeq ($(BR2_PACKAGE_DHCP_CLIENT)$(BR2_PACKAGE_PROCPS_NG),yy)
ROOTFS_DRACUT_HAS_NETWORK=y
ROOTFS_DRACUT_MODULES_INCLUDE += network network-legacy
ROOTFS_DRACUT_MODULES_OMIT += network-manager
else
ROOTFS_DRACUT_HAS_NETWORK=n
ROOTFS_DRACUT_MODULES_OMIT += network network-legacy network-manager
endif

ifeq ($(BR2_PACKAGE_OPENSSH)$(BR2_PACKAGE_OPENSSH_CLIENT)$(ROOTFS_DRACUT_HAS_NETWORK),yyy)
ROOTFS_DRACUT_MODULES_INCLUDE += ssh-client
else
ROOTFS_DRACUT_MODULES_OMIT += ssh-client
endif

ifeq ($(BR2_TARGET_GENERIC_REMOUNT_ROOTFS_RW),y)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --ro-mnt
endif

ifeq ($(BR2_INIT_BUSYBOX),y)
ROOTFS_DRACUT_MODULES_INCLUDE += busybox-buildroot
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
# Environment variables used to execute dracut
# We have to unset "prefix" as dracut uses it to move files around.
# Dracut doesn't support decimal points for the systemd version.
ROOTFS_DRACUT_SYSTEMD_VERSION_SANATIZED=`echo $(SYSTEMD_VERSION) |cut -d . -f 1`
ROOTFS_DRACUT_MODULES_INCLUDE += \
	dbus-daemon \
	dracut-systemd \
	systemd \
	systemd-ac-power \
	systemd-ask-password \
	systemd-initrd \
	systemd-journald \
	systemd-modules-load \
	systemd-sysctl \
	systemd-tmpfiles \
	systemd-udevd \
	systemd-veritysetup

# Dbus variables taken from dracut.conf.d/fedora.conf.example
ROOTFS_DRACUT_FS_ENV += \
	dbus=/usr/share/dbus-1 \
	dbusinterfaces=/usr/share/dbus-1/interfaces \
	dbusservices=/usr/share/dbus-1/services \
	dbussession=/usr/share/dbus-1/session.d \
	dbussystem=/usr/share/dbus-1/system.d \
	dbussystemservices=/usr/share/dbus-1/system-services \
	dbusconfdir=/etc/dbus-1 \
	dbusinterfacesconfdir=/etc/dbus-1/interfaces \
	dbusservicesconfdir=/etc/dbus-1/services \
	dbussessionconfdir=/etc/dbus-1/session.d \
	dbussystemconfdir=/etc/dbus-1/system.d \
	dbussystemservicesconfdir=/etc/dbus-1/system-services \
	dbussystemservicesconfdir=$(TARGET_DIR)/etc/dbus-1/system-services \
	SYSTEMCTL="$(HOST_DIR)/bin/systemctl" \
	systemctlpath="$(HOST_DIR)/bin/systemctl" \
	systemdsystemconfdir="/etc/systemd/system" \
	systemdsystemunitdir="/usr/lib/systemd/system" \
	systemdutildir="/usr/lib/systemd" \
	systemdutilconfdir="/etc/systemd" \
	SYSTEMD_VERSION=$(ROOTFS_DRACUT_SYSTEMD_VERSION_SANATIZED) \
	UDEVVERSION=$(ROOTFS_DRACUT_SYSTEMD_VERSION_SANATIZED)

ifeq ($(BR2_PACKAGE_CRYPTSETUP),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-integritysetup
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-integritysetup
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_COREDUMP),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-coredump
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-coredump
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_PORTABLED),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-portabled
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-portabled
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_SYSUSERS)$(BR2_PACKAGE_SYSTEMD_HOSTNAMED),yy)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-hostnamed
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-hostnamed
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_REPART),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-repart
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-repart
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_RFKILL),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-rfkill
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-rfkill
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_SYSUSERS),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-sysusers
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-sysusers
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_SYSEXT),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-sysext
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-sysext
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_SYSUSERS)$(BR2_PACKAGE_SYSTEMD_RESOLVED),yy)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-resolved
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-resolved
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_SYSUSERS)$(BR2_PACKAGE_SYSTEMD_NETWORKD),yy)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-networkd
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-networkd
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_TIMEDATED),y)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-timedated
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-timedated
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_TIMEDATED)$(BR2_PACKAGE_SYSTEMD_TIMESYNCD),yy)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-timesyncd
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-timesyncd
endif

ifeq ($(BR2_PACKAGE_SYSTEMD_HOSTNAMED)$(BR2_PACKAGE_SYSTEMD_NETWORKD)$(BR2_PACKAGE_SYSTEMD_RESOLVED)$(BR2_PACKAGE_SYSTEMD_TIMEDATED)$(BR2_PACKAGE_SYSTEMD_TIMESYNCD),yyyyy)
ROOTFS_DRACUT_MODULES_INCLUDE += systemd-network-management
else
ROOTFS_DRACUT_MODULES_OMIT += systemd-network-management
endif

else # ifeq ($(BR2_PACKAGE_SYSTEMD)$(BR2_PACKAGE_SYSTEMD_INITRD),yy)
ROOTFS_DRACUT_UDEV_VERSION_SANATIZED=`echo $(EUDEV_VERSION) |cut -d . -f 1`
ROOTFS_DRACUT_FS_ENV += UDEVVERSION=$(ROOTFS_DRACUT_UDEV_VERSION_SANATIZED)
endif

ifeq ($(BR2_PACKAGE_UTIL_LINUX_HWCLOCK),y)
ROOTFS_DRACUT_MODULES_INCLUDE += warpclock
else
ROOTFS_DRACUT_MODULES_OMIT += warpclock
endif

ifeq ($(BR2_TARGET_ROOTFS_DRACUT_MOD_SIG),y)
ROOTFS_DRACUT_DEPENDENCIES += keyutils
ROOTFS_DRACUT_MODULES_INCLUDE += modsign
else
ROOTFS_DRACUT_MODULES_OMIT += modsign
endif

ROOTFS_DRACUT_KERNEL_MODULES = $(call qstrip,$(BR2_TARGET_ROOTFS_DRACUT_KERNEL_MODULES))
ROOTFS_DRACUT_MODULES_INCLUDE += $(call qstrip,$(BR2_TARGET_ROOTFS_DRACUT_MODULES))
ROOTFS_DRACUT_CUSTOM_KERNEL_CMDLINE = $(call qstrip,$(BR2_TARGET_ROOTFS_DRACUT_CUSTOM_KERNEL_CMDLINE))
ROOTFS_DRACUT_COMPRESSION_METHOD = $(call qstrip,$(BR2_TARGET_ROOTFS_DRACUT_COMPRESSION_METHOD))
ROOTFS_DRACUT_CONF_PATH = $(call qstrip,$(BR2_TARGET_ROOTFS_DRACUT_CONF_PATH))
ROOTFS_DRACUT_MKFS_CONF_OPTS += \
	--omit="$(ROOTFS_DRACUT_MODULES_OMIT)" \
	--drivers=$(ROOTFS_DRACUT_KERNEL_MODULES) \
	--$(ROOTFS_DRACUT_COMPRESSION_METHOD)

ifeq ($(ROOTFS_DRACUT_CONF_PATH),y)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --modules="$(ROOTFS_DRACUT_MODULES_INCLUDE)"
else
ROOTFS_DRACUT_MKFS_CONF_OPTS += --conf=$(ROOTFS_DRACUT_CONF_PATH)
endif

ifneq ($(ROOTFS_DRACUT_CUSTOM_KERNEL_CMDLINE),)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --kernel-cmdline=$(ROOTFS_DRACUT_CUSTOM_KERNEL_CMDLINE)
endif

ifeq ($(BR2_LINUX_KERNEL),y)
ROOTFS_DRACUT_KERNEL_IMAGE_PATH=$(BINARIES_DIR)/$(LINUX_TARGET_NAME)
ROOTFS_DRACUT_KERNEL_VERSION=$(LINUX_VERSION_PROBED)

ROOTFS_DRACUT_MKFS_CONF_OPTS += \
	--kver=$(ROOTFS_DRACUT_KERNEL_VERSION) \
	--kernel-image=$(ROOTFS_DRACUT_KERNEL_IMAGE_PATH) \
	--kmoddir="$(ROOTFS_DRACUT_TARGET_DIR)/lib/modules/$(ROOTFS_DRACUT_KERNEL_VERSION)"

ROOTFS_DRACUT_FS_ENV += KERNEL_VERSION=$(ROOTFS_DRACUT_KERNEL_VERSION)
ROOTFS_DRACUT_MODULES_INCLUDE += kernel-modules
endif

ifeq ($(BR2_TARGET_ROOTFS_DRACUT_HOST_ONLY),y)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --hostonly
ROOTFS_DRACUT_MKFS_CONF_OPTS += --no-hostonly-cmdline
ifeq ($(BR2_TARGET_ROOTFS_DRACUT_HOST_ONLY_SLOPPY),y)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --hostonly-mode=sloppy
else
ROOTFS_DRACUT_MKFS_CONF_OPTS += --hostonly-mode=strict
endif
else
ROOTFS_DRACUT_MKFS_CONF_OPTS += --no-hostonly
endif

ifeq ($(BR2_STRIP_strip),y)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --aggressive-strip
else
ROOTFS_DRACUT_MKFS_CONF_OPTS += --nostrip
endif

ifeq ($(BR2_REPRODUCIBLE),y)
ROOTFS_DRACUT_MKFS_CONF_OPTS += --reproducible
else
ROOTFS_DRACUT_MKFS_CONF_OPTS += --no-reproducible
endif

define ROOTFS_DRACUT_CMD
	(mkdir -p $(ROOTFS_DRACUT_DIR)/rootfs.dracut.tmp && \
		$(ROOTFS_DRACUT_FS_ENV) \
		$(HOST_DIR)/bin/dracut \
		$(ROOTFS_DRACUT_MKFS_CONF_OPTS) \
		$(BINARIES_DIR)/rootfs.cpio)
endef

$(eval $(rootfs))

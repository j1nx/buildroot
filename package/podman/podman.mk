################################################################################
#
# podman
#
################################################################################

PODMAN_VERSION = 5.2.0-rc2
PODMAN_SITE = $(call github,containers,podman,v$(PODMAN_VERSION))
PODMAN_LICENSE = Apache-2.0
PODMAN_LICENSE_FILES = LICENSE

PODMAN_CPE_ID_VENDOR = podman_project
PODMAN_GOMOD = github.com/containers/podman/v5

PODMAN_BUILD_TARGETS = cmd/podman cmd/rootlessport cmd/quadlet
PODMAN_DEPENDENCIES += libglib2 libgpgme
PODMAN_LDFLAGS = \
	-X $(PODMAN_GOMOD)/libpod/define.gitCommit=$(PODMAN_VERSION)
PODMAN_TAGS = exclude_graphdriver_zfs

ifeq ($(BR2_PACKAGE_ARGP_STANDALONE),y)
PODMAN_DEPENDENCIES += argp-standalone
endif

ifeq ($(BR2_INIT_SYSTEMD),y)
PODMAN_TAGS += systemd
endif

ifeq ($(BR2_PACKAGE_LIBAPPARMOR),y)
PODMAN_DEPENDENCIES += libapparmor
PODMAN_TAGS += apparmor
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
PODMAN_TAGS += seccomp
PODMAN_DEPENDENCIES += libseccomp host-pkgconf
endif

ifeq ($(BR2_PACKAGE_LIBSELINUX),y)
PODMAN_TAGS += selinux
PODMAN_DEPENDENCIES += libselinux
endif

ifeq ($(BR2_PACKAGE_PODMAN_DRIVER_BTRFS),y)
PODMAN_DEPENDENCIES += btrfs-progs
else
PODMAN_TAGS += exclude_graphdriver_btrfs
endif

ifeq ($(BR2_PACKAGE_PODMAN_DRIVER_DEVICEMAPPER),y)
PODMAN_DEPENDENCIES += lvm2
else
PODMAN_TAGS += exclude_graphdriver_devicemapper
endif

ifeq ($(BR2_PACKAGE_PODMAN_DRIVER_VFS),y)
PODMAN_DEPENDENCIES += gvfs
else
PODMAN_TAGS += exclude_graphdriver_vfs
endif

define PODMAN_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) PREFIX=/usr \
		install.bin
	$(INSTALL) -d -m 755 $(TARGET_DIR)/etc/containers
	$(INSTALL) -D -m 644 $(PODMAN_PKGDIR)/containers-policy.json \
		$(TARGET_DIR)/etc/containers/policy.json
endef

define PODMAN_INSTALL_INIT_SYSTEMD
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) PREFIX=/usr \
		install.systemd
endef

HOST_PODMAN_BUILD_TARGETS = cmd/podman
HOST_PODMAN_DEPENDENCIES += host-libglib2 host-libgpgme
HOST_PODMAN_LDFLAGS = $(PODMAN_LDFLAGS)
HOST_PODMAN_GO_ENV = GOFLAGS="-mod=mod" GOPROXY=direct
HOST_PODMAN_TAGS = exclude_graphdriver_zfs \
		exclude_graphdriver_btrfs \
		exclude_graphdriver_vfs

$(eval $(golang-package))
$(eval $(host-golang-package))

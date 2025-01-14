################################################################################
#
# skopeo
#
################################################################################

SKOPEO_VERSION = 1.14.2
SKOPEO_SITE = $(call github,containers,skopeo,v$(SKOPEO_VERSION))

SKOPEO_LICENSE = Apache-2.0
SKOPEO_LICENSE_FILES = LICENSE

HOST_SKOPEO_DEPENDENCIES = \
	host-btrfs-progs \
	host-libgpgme \
	host-lvm2 \
	host-pkgconf

HOST_SKOPEO_GO_ENV = PKG_CONFIG_PATH=$(HOST_DIR)/lib/pkgconfig
HOST_SKOPEO_BUILD_TARGETS = cmd/skopeo

$(eval $(host-golang-package))

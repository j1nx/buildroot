################################################################################
#
# netavark
#
################################################################################

NETAVARK_VERSION = 1.11.0
NETAVARK_SITE = $(call github,containers,netavark,v$(NETAVARK_VERSION))
NETAVARK_DEPENDENCIES = host-rustc host-pkgconf protobuf

NETAVARK_CARGO_ENV = PKG_CONFIG_ALLOW_CROSS=1

define NETAVARK_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/libexec/podman
	$(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/netavark \
		$(TARGET_DIR)/usr/libexec/podman/netavark
endef

$(eval $(cargo-package))

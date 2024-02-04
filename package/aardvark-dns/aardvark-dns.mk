################################################################################
#
# aardvark-dns.mk
#
################################################################################

AARDVARK_DNS_VERSION = 1.10.0
AARDVARK_DNS_SITE = $(call github,containers,aardvark-dns,v$(AARDVARK_DNS_VERSION))
AARDVARK_DNS_DEPENDENCIES = host-rustc host-pkgconf

AARDVARK_DNS_CARGO_ENV = PKG_CONFIG_ALLOW_CROSS=1

define AARDVARK_DNS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(@D)/target/$(RUSTC_TARGET_NAME)/release/aardvark-dns \
		$(TARGET_DIR)/usr/bin/aardvark-dns
endef

$(eval $(cargo-package))

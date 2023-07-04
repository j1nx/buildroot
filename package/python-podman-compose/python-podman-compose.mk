################################################################################
#
# python-podman-compose
#
################################################################################

PYTHON_PODMAN_COMPOSE_VERSION = 1.0.6
PYTHON_PODMAN_COMPOSE_SOURCE = podman-compose-$(PYTHON_PODMAN_COMPOSE_VERSION).tar.gz
PYTHON_PODMAN_COMPOSE_SITE = https://files.pythonhosted.org/packages/65/a8/d77d2eaa85414d013047584d3aa10fac47edb328f5180ca54a13543af03a
PYTHON_PODMAN_COMPOSE_SETUP_TYPE = setuptools
PYTHON_PODMAN_COMPOSE_LICENSE = GNU General Public License v2 (GPLv2)
PYTHON_PODMAN_COMPOSE_LICENSE_FILES = LICENSE

$(eval $(python-package))

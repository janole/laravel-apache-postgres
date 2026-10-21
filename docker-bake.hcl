# Image variant tree. Each variant builds FROM its parent via `contexts = { base = ... }`;
# bake resolves the graph and builds independent branches in parallel.
#
#   php83 ─┬─ php83-node      (Debian 12 bookworm: imap needs uw-imap, gone in Debian 13)
#          └─ php83-xdebug
#   php84 ─── php84-node      (Debian 13 trixie)
#   php85 ─┬─ php85-node      (Debian 13 trixie)
#          └─ php85-xdebug
#
# Base targets (the ones with BASE_IMAGE) are discovered by CI from `bake --print`; their
# variable must be named PHP<major><minor>_BASE, e.g. PHP85_BASE for target php85.
#
# Retired (revive by adding a target): php83-xdebug-node, php83-node-xdebug.
#
# Local use: see build.sh. CI: see .github/workflows/build.yml.

variable "IMAGE" {
  default = "janole/laravel-apache-postgres"
}

# Contents of ./version, e.g. "0.8". Passed in by build.sh and CI.
variable "VERSION" {
  default = "0.8"
}

# Empty = the builder's native platform only (arm64 on Apple silicon, no QEMU).
# Comma-separated list to force more, e.g. "linux/amd64,linux/arm64".
variable "PLATFORMS" {
  default = ""
}

# Upstream images. CI pins these by digest so both architectures use the same base.
variable "PHP83_BASE" {
  default = "php:8.3-apache-bookworm"
}

variable "PHP84_BASE" {
  default = "php:8.4-apache-trixie"
}

variable "PHP85_BASE" {
  default = "php:8.5-apache-trixie"
}

function "tags" {
  params = [name]
  result = [
    "${IMAGE}:${element(split(".", VERSION), 0)}-${name}",
    "${IMAGE}:${VERSION}-${name}",
  ]
}

group "default" {
  targets = [
    "php83", "php83-node", "php83-xdebug",
    "php84", "php84-node",
    "php85", "php85-node", "php85-xdebug",
  ]
}

target "_common" {
  platforms = PLATFORMS == "" ? [] : split(",", PLATFORMS)
  labels = {
    "maintainer"                    = "Jan Ole Suhr <ole@janole.com>"
    "org.opencontainers.image.source" = "https://github.com/janole/laravel-apache-postgres"
  }
}

target "php83" {
  inherits   = ["_common"]
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    BASE_IMAGE     = PHP83_BASE
    PHP_EXTENSIONS = "gd pgsql pdo_pgsql zip gmp bcmath intl opcache imap"
  }
  labels = {
    "org.opencontainers.image.base.name" = PHP83_BASE
  }
  tags = tags("php83")
}

target "php83-node" {
  inherits = ["_common"]
  context  = "variants/node"
  contexts = { base = "target:php83" }
  tags     = tags("php83-node")
}

target "php83-xdebug" {
  inherits = ["_common"]
  context  = "variants/xdebug"
  contexts = { base = "target:php83" }
  tags     = tags("php83-xdebug")
}

target "php84" {
  inherits   = ["_common"]
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    BASE_IMAGE     = PHP84_BASE
    PHP_EXTENSIONS = "gd pgsql pdo_pgsql zip gmp bcmath intl opcache exif"
  }
  labels = {
    "org.opencontainers.image.base.name" = PHP84_BASE
  }
  tags = tags("php84")
}

target "php84-node" {
  inherits = ["_common"]
  context  = "variants/node"
  contexts = { base = "target:php84" }
  tags     = tags("php84-node")
}

target "php85" {
  inherits   = ["_common"]
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    BASE_IMAGE     = PHP85_BASE
    PHP_EXTENSIONS = "gd pgsql pdo_pgsql zip gmp bcmath intl exif"
  }
  labels = {
    "org.opencontainers.image.base.name" = PHP85_BASE
  }
  tags = tags("php85")
}

target "php85-node" {
  inherits = ["_common"]
  context  = "variants/node"
  contexts = { base = "target:php85" }
  tags     = tags("php85-node")
}

target "php85-xdebug" {
  inherits = ["_common"]
  context  = "variants/xdebug"
  contexts = { base = "target:php85" }
  tags     = tags("php85-xdebug")
}

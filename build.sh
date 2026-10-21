#!/bin/sh
# Build the image variants locally with docker buildx bake (see docker-bake.hcl).
#
#   ./build.sh                    all variants, native platform only, loaded into local Docker
#   ./build.sh php83 php83-node   only these targets (parents are built as needed)
#   ./build.sh --all-platforms    linux/amd64 + linux/arm64 (the foreign one runs under QEMU)
#   ./build.sh --push             push the moving tags (0-*, <version>-*) instead of loading
#   ./build.sh --print            show the resolved bake definition and exit
#
# CI does not use this script: .github/workflows/build.yml builds each architecture on a
# native runner and merges the results.
set -e

cd "$(dirname "$0")"

VERSION=$(cat version)
export VERSION

OUTPUT="--load"
TARGETS=""

while [ $# -gt 0 ]; do
    case "$1" in
        --all-platforms) PLATFORMS="linux/amd64,linux/arm64"; export PLATFORMS ;;
        --push) OUTPUT="--push" ;;
        --print) OUTPUT="--print" ;;
        -h|--help) sed -n '2,11p' "$0"; exit 0 ;;
        -*) echo "Unknown option: $1" >&2; exit 1 ;;
        *) TARGETS="$TARGETS $1" ;;
    esac
    shift
done

# shellcheck disable=SC2086 # TARGETS is a word list on purpose
exec docker buildx bake $OUTPUT $TARGETS

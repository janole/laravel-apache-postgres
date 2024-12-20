#!/bin/sh
set -e

#
IMAGE=${DOCKER_ID:=janole}/laravel-apache-postgres
VERSION=`cat version`

#
MAINTAINER=${DOCKER_MAINTAINER:=Jan Ole Suhr <ole@janole.com>}

# Branch or Tag ...
if [ -n "${GITHUB_REF}" ]; then
    BRANCH=`echo ${GITHUB_REF} | sed 's=.*/==' | grep -v "^master$" || true`;
else
    BRANCH=`(git rev-parse --abbrev-ref HEAD 2>/dev/null) | grep -v "^master$" || true`;
fi

# If branch equals version, do not duplicate!
if [ "${BRANCH}" = "${VERSION}" ]; then
    unset BRANCH
fi

if [ -n "${BRANCH}" ]; then
    BRANCH=-${BRANCH};
fi

#
COUNT=`git rev-list HEAD --count 2>/dev/null`

# append "-manual" to image name if triggered manually
if [ "${GITHUB_EVENT_NAME}" = "workflow_dispatch" ]; then
    COUNT="${COUNT}-manual"
fi

#
VERSION=${VERSION}.${COUNT}${BRANCH}

# Create hierarchical versions (1.2.3 => "1.2" and "1")
VERSION1=`sed "s/\(^[0-9]*\.[0-9]*\).*/\1/" version`${BRANCH}
VERSION0=`sed "s/\(^[0-9]*\).*/\1/" version`${BRANCH}

#
TARGET=${IMAGE}:${VERSION}

#
if [ "$1" = "-p" ]; then echo $TARGET; exit; fi

#
if [ "$1" = "--dry-run" ]; then DOCKER="echo docker"; else DOCKER="docker"; fi

#
if [ "$1" = "--no-push" ]; then PUSH=""; else PUSH="--push"; fi

#
build()
{
    local _DOCKERFILE=$1
    local _SUFFIX=$2
    local _FROM=$3

    local _TARGET=${IMAGE}:${VERSION}${_SUFFIX}
    local _TARGET1=${IMAGE}:${VERSION1}${_SUFFIX}
    local _TARGET0=${IMAGE}:${VERSION0}${_SUFFIX}

    local _CONTEXT=`dirname $_DOCKERFILE`

    echo "*** Build ${_TARGET} ${_DOCKERFILE} ${_FROM}"

    # always try to pull base image, but only for main Dockerfile
    if [ -z "$_FROM" ]; then PULL="--pull"; else PULL=""; fi

    # build image and tag it with all subversions
    $DOCKER buildx build $PUSH $PLATFORM $PULL --label "maintainer=${MAINTAINER}" --build-arg "FROM=${_FROM}" -t "${_TARGET}" -t "${_TARGET1}" -t "${_TARGET0}" -f ${_DOCKERFILE} $_CONTEXT
}

for base in Dockerfile* ; do

    ALT=`echo $base | sed "s/Dockerfile//;s/^\./-/;"`

    # build the base-image
    build $base $ALT

    # build all variants
    for variant in */Dockerfile ; do
        SUFFIX=$ALT-`dirname $variant`
        build $variant $SUFFIX $TARGET$ALT
    done

done

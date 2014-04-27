#!/usr/bin/env bash
#
# init.sh
# Setup initial globals and load function used to source other modules.

# These globals can be set by a user to use a custom ellipsis fork/set of packages/etc

# git config returns 1 if key isn't found, so we pipe to cat to squash that in
# the case it's not-defined.
if [[ -z "$ELLIPSIS_USER" ]]; then
    GITHUB_USER=$(git config github.user | cat)
    ELLIPSIS_USER=${GITHUB_USER:-zeekay}
fi

# Repostitory defaults.
ELLIPSIS_PROTO="${ELLIPSIS_PROTO:-https}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"

# Default locations for ellipsis and packages.
ELLIPSIS_HOME="$HOME"
ELLIPSIS_PATH="${ELLIPSIS_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Ellipsis is the default package.
PKG_PATH=${PKG_PATH:-$ELLIPSIS_PATH}
PKG_NAME=${PKG_NAME:-${PKG_PATH##*/.}}

# Utility to load other modules.
load() {
    source $ELLIPSIS_PATH/src/$1.sh
}

# Load version info.
load version

# Set flag that we've been sourced already.
ELLIPSIS_INIT=1

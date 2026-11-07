#!/usr/bin/env bash

# Initialize Intel tools for arbitrary users and noninteractive commands.
set -e
if (( $# == 0 )); then
    printf 'Usage: with-oneapi <command> [arguments...]\n' >&2
    exit 2
fi
# Intel's environment scripts are not required to support nounset.
# shellcheck disable=SC1091
source /opt/intel/oneapi/setvars.sh > /dev/null
exec "${@}"

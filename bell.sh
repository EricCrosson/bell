#!/usr/bin/env bash
# Written by Eric Crosson
# 2017-04-10
#
# Trigger the audial/visual bell $1 times.
#
# Usage:
#  bell [<times>]
#
# Options:
#   <times>    Number of times to ring the bell
#
# @example
# bell
#
# @example
# bell 42

set -o errexit
set -o nounset
set -o pipefail

usage() {
  cat <<EOF

Usage:
 bell [<times>]

Options:
  <times>    Number of times to ring the bell
EOF
}

times=1

# Parse arguments
while [ "${1:-}" != "" ]; do
  case "$1" in
  # Matches every non-integer argument, including -h and --help
  *[!0-9]*)
    usage
    exit 1
    ;;
  # A valid integer argument
  *)
    times=$1
    shift # past value
    ;;
  esac
done

tput smcup # activate alternate screen
tput civis # invisible cursor
for i in $(seq 1 $times); do
  echo -e '\a'
  sleep 0.15
done
tput cnorm # normal cursor
tput rmcup # deactivate alternate screen

#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

VERSION=0.0.1

usage() {
  cat <<EOF
USAGE:
    $(basename "${BASH_SOURCE[0]}") [FLAGS] <version>

FLAGS:
    -h, --help      Prints help information
    -v, --version   Prints version information
    --no-color      Uses plain text output

ARGS:
    <version>       WildFly version >=10 as <major>[.<minor>]
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    # shellcheck disable=SC2034
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

version() {
  msg "${BASH_SOURCE[0]} $VERSION"
  exit 0
}

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --version) version ;;
    --no-color) NO_COLOR=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  ARGS=("$@")
  [[ ${#ARGS[@]} -eq 0 ]] && die "Missing WildFly version"

  WF_VERSION=${ARGS[0]}
  [[ $WF_VERSION =~ ^([0-9]{2})(\.([0-9]{1}))?$ ]] || die "Illegal WildFly version: '$WF_VERSION'. Please use <major>[.<minor>] with mandatory major >= 10 and optional minor >= 0 and <= 9"

  WF_MAJOR_VERSION=${BASH_REMATCH[1]}
  [[ "${WF_MAJOR_VERSION}" -lt "10" ]] && die "Illegal major WildFly version: '$WF_MAJOR_VERSION'. Must be >= 10"

  WF_MINOR_VERSION=${BASH_REMATCH[3]:-0}
  [[ "${WF_MINOR_VERSION}" -lt "0" ]] && die "Illegal minor WildFly version: '$WF_MINOR_VERSION'. Must be >= 0"
  [[ "${WF_MINOR_VERSION}" -gt "9" ]] && die "Illegal major WildFly version: '$WF_MINOR_VERSION'. Must be <= 9"

  return 0
}

parse_params "$@"
setup_colors

RELEASE=$WF_MAJOR_VERSION.$WF_MINOR_VERSION.0.Final
HTTP_PORT=$([[ "$WF_MINOR_VERSION" -eq "0" ]] && echo "80${WF_MAJOR_VERSION}" || echo "8${WF_MAJOR_VERSION}${WF_MINOR_VERSION}")
BROWSER=unknown
if [[ $OSTYPE == "darwin"* ]]; then
  BROWSER=open
elif [[ -x "$(command -v gnome-open)" ]]; then
  BROWSER=gnome-open
elif [[ -x "$(command -v xdg-open)" ]]; then
  BROWSER=xdg-open
else
  die "No browser found."
fi

msg "Open WildFly ${CYAN}${RELEASE}${NOFORMAT} Management Console on port ${YELLOW}${HTTP_PORT}"
$BROWSER "http://admin:admin@localhost:${HTTP_PORT}"

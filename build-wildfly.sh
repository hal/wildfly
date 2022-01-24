#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

VERSION=0.0.1

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
readonly script_dir
cd "${script_dir}"

usage() {
  cat <<EOF
USAGE: 
    $(basename "${BASH_SOURCE[0]}") [FLAGS] <version>

FLAGS:
    -p, --podman    Use podman instead of docker
    -h, --help      Prints help information
    -v, --version   Prints version information
    --no-color      Uses plain text output

ARGS: 
    <version>       WildFly major version >=10 as [nn] 
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
  DOCKER=docker
  while :; do
    case "${1-}" in
    -p | --podman) DOCKER=podman ;;
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
  [[ $WF_VERSION =~ ^[0-9]{2}$ ]] || die "Illegal WildFly version: $WF_VERSION. Please use a two digit version >= 10"
  [[ "$WF_VERSION" -lt "10" ]] && die "Illegal WildFly version: $WF_VERSION. Please use a two digit version >= 10"

  return 0
}

parse_params "$@"
setup_colors

RELEASE=$WF_VERSION.0.0.Final
TAG=quay.io/halconsole/wildfly
BASE=quay.io/wildfly/wildfly
# Starting with WildFly 24, we use quay.io
# for the WildFly images.
if [[ "$WF_VERSION" -lt "24" ]]; then
  BASE=docker.io/jboss/wildfly
fi

${DOCKER} build \
  --build-arg WILDFLY_RELEASE="${RELEASE}" \
  --build-arg DOCKER_BASE="${BASE}" \
  --file Dockerfile \
  --tag "${TAG}:${RELEASE}" \
  .

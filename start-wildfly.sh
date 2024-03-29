#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

VERSION=0.0.1

usage() {
  cat <<EOF
USAGE:
    $(basename "${BASH_SOURCE[0]}") [FLAGS] <version> [<parameters>]

FLAGS:
    -d, --domain    Start in domain mode
    -p, --podman    Use podman instead of docker
    -h, --help      Prints help information
    -v, --version   Prints version information
    --no-color      Uses plain text output

ARGS:
    <version>       WildFly version >=10 as <major>[.<minor>]
    <parameters>    Parameters passed to standalone.sh | domain.sh
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
  MODE=standalone
  DOCKER=docker
  while :; do
    case "${1-}" in
    -d | --domain) MODE=domain ;;
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
  [[ $WF_VERSION =~ ^([0-9]{2})(\.([0-9]{1}))?$ ]] || die "Illegal WildFly version: '$WF_VERSION'. Please use <major>[.<minor>] with mandatory major >= 10 and optional minor >= 0 and <= 9"

  WF_MAJOR_VERSION=${BASH_REMATCH[1]}
  [[ "${WF_MAJOR_VERSION}" -lt "10" ]] && die "Illegal major WildFly version: '$WF_MAJOR_VERSION'. Must be >= 10"

  WF_MINOR_VERSION=${BASH_REMATCH[3]:-0}
  [[ "${WF_MINOR_VERSION}" -lt "0" ]] && die "Illegal minor WildFly version: '$WF_MINOR_VERSION'. Must be >= 0"
  [[ "${WF_MINOR_VERSION}" -gt "9" ]] && die "Illegal major WildFly version: '$WF_MINOR_VERSION'. Must be <= 9"

  shift
  WF_PARAM="$*"
  return 0
}

parse_params "$@"
setup_colors

TAG=quay.io/halconsole/wildfly
TAG_DOMAIN=quay.io/halconsole/wildfly-domain
RELEASE=$WF_MAJOR_VERSION.$WF_MINOR_VERSION.0.Final
HTTP_PORT=$([[ "$WF_MINOR_VERSION" -eq "0" ]] && echo "80${WF_MAJOR_VERSION}" || echo "8${WF_MAJOR_VERSION}${WF_MINOR_VERSION}")
MGMT_PORT=$([[ "$WF_MINOR_VERSION" -eq "0" ]] && echo "99${WF_MAJOR_VERSION}" || echo "9${WF_MAJOR_VERSION}${WF_MINOR_VERSION}")

msg "Start WildFly ${CYAN}${RELEASE}${NOFORMAT} in ${CYAN}${MODE}${NOFORMAT} mode using"
msg "    ${YELLOW}${HTTP_PORT}${NOFORMAT} for HTTP endpoint and"
msg "    ${YELLOW}${MGMT_PORT}${NOFORMAT} for management endpoint"

# Please don't put double quotes around ${WF_PARAM-}
if [[ "${MODE}" == "standalone" ]]; then
  ${DOCKER} run \
    --rm \
    --name="hal-wildfly-${WF_VERSION}" \
    --publish="${HTTP_PORT}:8080" \
    --publish="${MGMT_PORT}:9990" \
    "${TAG}:${RELEASE}" ${WF_PARAM-}
elif [[ "${MODE}" == "domain" ]]; then
  ${DOCKER} run \
    --rm \
    --name="hal-wildfly-domain-${WF_VERSION}" \
    --publish="${HTTP_PORT}:8080" \
    --publish="${MGMT_PORT}:9990" \
    "${TAG_DOMAIN}:${RELEASE}" ${WF_PARAM-}
else
  die "No operation mode (standalone|domain) given!"
fi

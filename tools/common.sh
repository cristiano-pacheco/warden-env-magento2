#!/usr/bin/env bash
set -euo pipefail
trap 'error "$(printf "Command \`%s\` on line $LINENO failed with exit code $?" "$BASH_COMMAND")"' ERR

## setup functions for use throughout the script
function warning {
  >&2 printf "\033[33mWARNING\033[0m: $@\n"
}

function error {
  >&2 printf "\033[31mERROR\033[0m: $@\n"
}

function info {
  >&2 printf "\033[32mINFO\033[0m: $@\n"
}

function fatal {
  error "$@"
  exit -1
}

function version {
  echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }';
}

function :: {
  echo
  echo "==> [$(date +%H:%M:%S)] $@"
}

## find directory above where this script is located following symlinks if neccessary
readonly BASE_DIR="$(
  cd "$(
    dirname "$(
      (readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}") \
        | sed -e "s#^../#$(dirname "$(dirname "${BASH_SOURCE[0]}")")/#"
    )"
  )/.." >/dev/null \
  && pwd
)"
cd "${BASE_DIR}"

## load configuration needed for setup
source .env
WARDEN_WEB_ROOT="$(echo "${WARDEN_WEB_ROOT:-/}" | sed 's#^/#./#')"
DB_DUMP="${DB_DUMP:-./backfill/magento-db.sql.gz}"
DB_IMPORT=1
CLEAN_INSTALL=
AUTO_PULL=1
META_PACKAGE="magento/project-community-edition"
META_VERSION=""
URL_FRONT="https://${TRAEFIK_SUBDOMAIN}.${TRAEFIK_DOMAIN}/"
URL_ADMIN="https://${TRAEFIK_SUBDOMAIN}.${TRAEFIK_DOMAIN}/backend/"

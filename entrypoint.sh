#!/usr/bin/env bash
#
# Environment variables:
# They are created from an input in a workflow file or a default value by
# GitHub, with the name INPUT_<VARIABLE_NAME>. Cf.,
# https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions.
#
# The following environment variables correspond to the input identifiers in
# action.yml.
#
# INPUT_RELEASE_TYPE
# INPUT_PERSIST_DIR
# INPUT_ARTIFACTS_DIR
# INPUT_ROOTFS_IMG_PATH
# INPUT_ZIP_ARCHIVE_PATH
# INPUT_BASE_INSTALL_PATH_ON_DEVICE
# INPUT_PROJECT_ACCESS_TOKEN
# INPUT_SIGNING_KEY_MANAGEMENT
# INPUT_SIGNING_KEY
# INPUT_SIGNING_KEY_PASSWORD
#

set -euxo pipefail

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SCRIPT_DIR
TRH_BINARY_PATH="${SCRIPT_DIR}/trh"
readonly TRH_BINARY_PATH
TRH_DOWNLOAD_URL="https://downloads.thistle.tech/embedded-client/1.0.0/trh-1.0.0-x86_64-unknown-linux-musl.gz"
readonly TRH_DOWNLOAD_URL

# Set environment variables
export THISTLE_KEY="${HOME}/.minisign/minisign.key"
export THISTLE_KEY_PASS="${INPUT_SIGNING_KEY_PASSWORD}"
export THISTLE_TOKEN="${INPUT_PROJECT_ACCESS_TOKEN}"

download_trh() {
  curl -A "curl (ota_release_action)" -L -o /tmp/trh.gz "${TRH_DOWNLOAD_URL}"
  gunzip -c /tmp/trh.gz > "${TRH_BINARY_PATH}"
  chmod +x "${TRH_BINARY_PATH}"
  "${TRH_BINARY_PATH}" --version
}

file_release() {
  # Hack alert: Need to do this to get a manifest template
  mkdir -p "$(dirname "${THISTLE_KEY}")"
  echo "${INPUT_SIGNING_KEY}" > "${THISTLE_KEY}"
  cat "${THISTLE_KEY}"
  "${TRH_BINARY_PATH}" init --persist="${INPUT_PERSIST_DIR}"

  local artifacts_dir="${INPUT_ARTIFACTS_DIR:-}"
  local base_install_path="${INPUT_BASE_INSTALL_PATH_ON_DEVICE:-}"
  [ -z "${artifacts_dir}" ] && { echo "No artifacts directory provided"; exit 1; }
  [ -z "${base_install_path}" ] && { echo "No base install path provided"; exit 1; }

  "${TRH_BINARY_PATH}" prepare --target="${artifacts_dir}" --file-base-path="${base_install_path}"

  "${TRH_BINARY_PATH}" release

  echo "done"
}

rootfs_release() {
    echo "Not implemented"
    exit 1
}

zip_archive_release() {
    echo "Not implemented"
    exit 1
}

do_it() {

  local release_type="${INPUT_RELEASE_TYPE:-}"
  [ -z "${release_type}" ] && { echo "No release type provided"; exit 1; }

  download_trh

  case "${INPUT_RELEASE_TYPE}" in
    "file")
      file_release
      ;;
    "rootfs")
      rootfs_release
      ;;
    "zip_archive")
      zip_archive_release
      ;;
    *)
      echo "Unknown release type: ${INPUT_RELEASE_TYPE}"
      exit 1
      ;;
  esac
}

do_it

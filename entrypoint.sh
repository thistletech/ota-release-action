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
# INPUT_RELEASE_NAME
# INPUT_RELEASE_TYPE
# INPUT_PERSIST_DIR_ON_DEVICE
# INPUT_ARTIFACTS_DIR
# INPUT_ROOTFS_IMG_PATH
# INPUT_ZIP_ARCHIVE_DIR
# INPUT_BASE_INSTALL_PATH_ON_DEVICE
# INPUT_PROJECT_ACCESS_TOKEN
# INPUT_SIGNING_KEY_MANAGEMENT
# INPUT_SIGNING_KEY
# INPUT_SIGNING_KEY_PASSWORD
# INPUT_BACKEND_URL
#

set -euxo pipefail

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly SCRIPT_DIR
TRH_BINARY_PATH="${SCRIPT_DIR}/trh"
readonly TRH_BINARY_PATH
TRH_DOWNLOAD_URL="https://downloads.thistle.tech/embedded-client/1.1.0/trh-1.1.0-x86_64-unknown-linux-musl.gz"
readonly TRH_DOWNLOAD_URL

# Set environment variables
export THISTLE_KEY="${HOME}/.minisign/minisign.key"
export THISTLE_KEY_PASS="${INPUT_SIGNING_KEY_PASSWORD}"
export THISTLE_TOKEN="${INPUT_PROJECT_ACCESS_TOKEN}"
[ -z "${INPUT_BACKEND_URL}" ] || export THISTLE_BACKEND="${INPUT_BACKEND_URL}"

err() {
  echo -e "$*"
  exit 1
}

download_trh() {
  curl -A "curl (thistletech/ota-release-action)" -L -o /tmp/trh.gz "${TRH_DOWNLOAD_URL}"
  gunzip -c /tmp/trh.gz > "${TRH_BINARY_PATH}"
  chmod +x "${TRH_BINARY_PATH}"
  "${TRH_BINARY_PATH}" --version
}

get_manifest_template_hack() {
  # Hack alert: Need to do this to get a manifest template
  local persist_dir="${INPUT_PERSIST_DIR_ON_DEVICE:-}"
  [ -z "${persist_dir}" ] && err "No persist directory provided"

  mkdir -p "$(dirname "${THISTLE_KEY}")"
  echo "${INPUT_SIGNING_KEY}" > "${THISTLE_KEY}"
  "${TRH_BINARY_PATH}" init --persist="${persist_dir}" > /dev/null
}

file_release() {
  get_manifest_template_hack

  local release_name="${INPUT_RELEASE_NAME:-}"

  local artifacts_dir="${INPUT_ARTIFACTS_DIR:-}"
  [ -z "${artifacts_dir}" ] && err "No artifacts directory provided"

  local base_install_path="${INPUT_BASE_INSTALL_PATH_ON_DEVICE:-}"
  [ -z "${base_install_path}" ] && err "No base install path provided"

  "${TRH_BINARY_PATH}" prepare --target="${artifacts_dir}" --file-base-path="${base_install_path}"

  if [ -n "${release_name}" ]; then
    "${TRH_BINARY_PATH}" release --name="${release_name}"
  else
    "${TRH_BINARY_PATH}" release
  fi 

  echo "done"
}

rootfs_release() {
  get_manifest_template_hack

  local release_name="${INPUT_RELEASE_NAME:-}"

  local rootfs_img_path="${INPUT_ROOTFS_IMG_PATH:-}"
  [ -z "${rootfs_img_path}" ] && err "No rootfs image path provided"

  "${TRH_BINARY_PATH}" prepare --target="${rootfs_img_path}"

  if [ -n "${release_name}" ]; then
    "${TRH_BINARY_PATH}" release --name="${release_name}"
  else
    "${TRH_BINARY_PATH}" release
  fi

  echo "done"
}

zip_archive_release() {
  get_manifest_template_hack

  local release_name="${INPUT_RELEASE_NAME:-}"

  local zip_archive_dir="${INPUT_ZIP_ARCHIVE_DIR:-}"
  [ -z "${zip_archive_dir}" ] && err "No zip archive directory provided"

  local base_install_path="${INPUT_BASE_INSTALL_PATH_ON_DEVICE:-}"
  [ -z "${base_install_path}" ] && err "No base install path provided"

  "${TRH_BINARY_PATH}" prepare --zip-target --target="${zip_archive_dir}" --file-base-path="${base_install_path}"

  if [ -n "${release_name}" ]; then
    "${TRH_BINARY_PATH}" release --name="${release_name}"
  else
    "${TRH_BINARY_PATH}" release
  fi

  echo "done"
}

do_it() {

  local release_type="${INPUT_RELEASE_TYPE:-}"
  [ -z "${release_type}" ] && err "No release type provided"

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
      err "Unknown release type: ${INPUT_RELEASE_TYPE}"
      ;;
  esac
}

do_it

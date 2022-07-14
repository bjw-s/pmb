#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

echo "Poor Man's Backup"
echo "--------------------------------"
echo "SOURCE DIR:          $PMB__SRC_DIR"
echo "DESTINATION DIR:     $PMB__DEST_DIR"
echo "FSFREEZE ENABLED:    $PMB__FSFREEZE"
echo "COMPRESSION ENABLED: $PMB__COMPRESSION"
echo "BACKUPS TO KEEP:     $PMB__KEEP_LATEST"
echo ""

if [[ -z "${PMB__SRC_DIR}" ]]; then
  echo "ERROR You need to set the PMB__SRC_DIR environment variable."
  exit 1
fi

if [[ ! -d "${PMB__SRC_DIR}" ]]; then
  echo "ERROR No such source directory: ${PMB__SRC_DIR}"
  exit 1
fi

if [[ -n "${PMB__DEST_DIR}" ]] && [[ ! -d "${PMB__DEST_DIR}" ]]; then
  echo "ERROR No such destination directory: ${PMB__DEST_DIR}"
  exit 1
fi

if [[ -z "${KOPIA_PASSWORD}" ]]; then
  echo "ERROR You need to set the KOPIA_PASSWORD environment variable."
  exit 1
fi

if [[ "${PMB__ACTION}" == "backup" && "${PMB__FSFREEZE}" == "true" && "${EUID}" != "0" ]]; then
  echo "ERROR fsfreeze requires the container to be running as root."
  exit 1
fi

if [[ "${PMB__ACTION}" == "restore" && -z "${PMB__NAMESPACE}" ]]; then
  echo "ERROR You need to set the PMB__NAMESPACE environment variable when restoring."
  exit 1
fi

if [[ "${PMB__ACTION}" == "restore" && -z "${PMB__CONTROLLER_NAME}" ]]; then
  echo "ERROR You need to set the PMB__CONTROLLER_NAME environment variable when restoring."
  exit 1
fi

exec "/app/${PMB__ACTION}.sh"

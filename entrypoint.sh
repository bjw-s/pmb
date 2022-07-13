#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

printf "Poor Man's Backup\n"
printf "%-18s\n" " " | tr ' ~' '- '
printf "%-18s%s\n" "SOURCE DIR:~" "~$PMB__SRC_DIR" | tr ' ~' '  '
printf "%-18s%s\n" "DESTINATION DIR:~" "~$PMB__DEST_DIR" | tr ' ~' '  '
printf "%-18s%s\n" "FSFREEZE ENABLED:~" "~$PMB__FSFREEZE" | tr ' ~' '  '
printf "\n"

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

if [[ "${PMB__ACTION}" == "backup" && "${PMB__FSFREEZE}" == "true" && "${EUID}" != "0" ]]; then
  echo "ERROR fsfreeze requires the container to be running as root."
  exit 1
fi

exec "/app/${PMB__ACTION}.sh"

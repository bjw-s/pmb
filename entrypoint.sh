#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

printf "Poor Man's Backup\n"
printf "%-18s\n" " " | tr ' ~' '- '
printf "%-18s%s\n" "MODE:~" "~$PMB__MODE" | tr ' ~' '  '
printf "%-18s%s\n" "SOURCE DIR:~" "~$PMB__SOURCE_DIR" | tr ' ~' '  '
printf "%-18s%s\n" "DESTINATION DIR:~" "~$PMB__DESTINATION_DIR" | tr ' ~' '  '
printf "%-18s%s\n" "RCLONE REMOTE:~" "~$PMB__RCLONE_REMOTE" | tr ' ~' '  '
printf "%-18s%s\n" "SCHEDULE:~" "~$PMB__CRON_SCHEDULE" | tr ' ~' '  '
printf "%-18s%s\n" "RETENTION:~" "~$PMB__KEEP_DAYS days" | tr ' ~' '  '
printf "%-18s%s\n" "EXCLUDE PATTERNS:~" "~$PMB__EXCLUDE_PATTERNS" | tr ' ~' '  '
printf "%-18s%s\n" "FSFREEZE ENABLED:~" "~$PMB__FSFREEZE" | tr ' ~' '  '
printf "\n"

if [[ -z "${PMB__SOURCE_DIR}" ]]; then
  echo "ERROR You need to set the PMB__SOURCE_DIR environment variable."
  exit 1
fi

if [[ ! -d "${PMB__SOURCE_DIR}" ]]; then
  echo "ERROR No such source directory: ${PMB__SOURCE_DIR}"
  exit 1
fi

if [[ -n "${PMB__DESTINATION_DIR}" ]] && [[ ! -d "${PMB__DESTINATION_DIR}" ]]; then
  echo "ERROR No such destination directory: ${PMB__DESTINATION_DIR}"
  exit 1
fi

if [[ "${PMB__FSFREEZE}" == "true" ]] && [[ "${EUID}" != "0" ]]; then
  echo "ERROR fsfreeze requires the container to be running as root."
  exit 1
fi

if [[ -n "${PMB__DESTINATION_DIR}" ]]; then
  rclone config create local_dir alias remote="${PMB__DESTINATION_DIR}" --config "${PMB__RCLONE_CONFIG}"
fi

if [[ "${PMB__MODE}" == "standalone" ]]; then
  exec /app/backup.sh
elif [[ "${PMB__MODE}" == "cron" ]]; then
  exec /usr/local/bin/go-cron -s "$PMB__CRON_SCHEDULE" -p "$PMB__CRON_HEALTHCHECK_PORT" -- /app/backup.sh
else
  echo "ERROR Only the following modes are supported: standalone, cron"
  exit 1
fi

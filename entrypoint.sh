#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

printf "Poor Man's Backup\n"
printf "%-17s\n" " " | tr ' ~' '- '
printf "%-17s%s\n" "MODE:~" "~$PMB__MODE" | tr ' ~' '  '
printf "%-17s%s\n" "SOURCE DIR:~" "~$PMB__SOURCE_DIR" | tr ' ~' '  '
printf "%-17s%s\n" "DESTINATION DIR:~" "~$PMB__DESTINATION_DIR" | tr ' ~' '  '
printf "%-17s%s\n" "RCLONE REMOTE:~" "~$PMB__RCLONE_REMOTE" | tr ' ~' '  '
printf "%-17s%s\n" "SCHEDULE:~" "~$PMB__CRON_SCHEDULE" | tr ' ~' '  '
printf "\n"

if [[ -z "${PMB__SOURCE_DIR}" ]]; then
  echo "ERROR You need to set the PMB__SOURCE_DIR environment variable."
  exit 1
fi

if [[ ! -d "${PMB__SOURCE_DIR}" ]]; then
  echo "ERROR No such source directory: ${PMB__SOURCE_DIR}"
  exit 1
fi

if [[ ! -z "${PMB__DESTINATION_DIR}" ]] && [[ ! -d "${PMB__DESTINATION_DIR}" ]]; then
  echo "ERROR No such destination directory: ${PMB__DESTINATION_DIR}"
  exit 1
fi

if [[ ! -z "${PMB__DESTINATION_DIR}" ]] && [[ -d "${PMB__DESTINATION_DIR}" ]]; then
cat <<EOF > "${PMB__RCLONE_CONFIG}"
[${PMB__RCLONE_REMOTE}]
type = alias
remote = ${PMB__DESTINATION_DIR}
EOF
fi

if [[ "${PMB__MODE}" == "standalone" ]]; then
  exec /app/backup.sh
elif [[ "${PMB__MODE}" == "cron" ]]; then
  exec /usr/local/bin/go-cron -s "$PMB__CRON_SCHEDULE" -p "$PMB__CRON_HEALTHCHECK_PORT" -- /app/backup.sh
else
  echo "ERROR Only the following modes are supported: standalone, cron"
  exit 1
fi

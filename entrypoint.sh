#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

printf "Poor Man's Backup\n"
printf "%-17s\n" " " | tr ' ~' '- '
printf "%-13s%s\n" "SOURCE:~" "~$PMB__SOURCE" | tr ' ~' '  '
printf "%-13s%s\n" "DESTINATION:~" "~$PMB__DESTINATION" | tr ' ~' '  '
printf "%-13s%s\n" "SCHEDULE:~" "~$PMB__CRON_SCHEDULE" | tr ' ~' '  '
printf "\n"

if [[ ! -f "${RCLONE_CONFIG}" ]]; then
cat <<EOF > "${RCLONE_CONFIG}"
[remote]
type = alias
remote = ${PMB__DESTINATION}
EOF
fi

if [[ -z "${PMB__CRON_SCHEDULE}" ]]; then
  exec /app/backup.sh
else
  exec /usr/local/bin/go-cron -s "$PMB__CRON_SCHEDULE" -p "$PMB__CRON_HEALTHCHECK_PORT" -- /app/backup.sh
fi

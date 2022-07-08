#!/usr/bin/env bash

#shellcheck disable=SC1091
test -f "/scripts/umask.sh" && source "/scripts/umask.sh"

printf "Poor Man's Backup\n"
printf "%-17s\n" " " | tr ' ~' '- '
printf "%-13s%s\n" "SOURCE:~" "~$PMB__SOURCE" | tr ' ~' '  '
printf "%-13s%s\n" "DESTINATION:~" "~$PMB__DESTINATION" | tr ' ~' '  '
printf "%-13s%s\n" "SCHEDULE:~" "~$PMB__SCHEDULE" | tr ' ~' '  '
printf "\n"

exec /usr/local/bin/go-cron -s "$PMB__SCHEDULE" -p "$PMB__HEALTHCHECK_PORT" -- /app/backup.sh

#!/usr/bin/env bash
set -eo pipefail

log() {
  printf "%s %s\n" "$1" "$2"
}

#Process vars
if [ "${PMB__SOURCE}" = "**None**" ]; then
  log "ERROR" "You need to set the PMB__SOURCE environment variable."
  exit 1
fi

if [ "${PMB__DESTINATION}" = "**None**" ]; then
  log "ERROR" "You need to set the PMB__DESTINATION environment variable."
  exit 1
fi

KEEP_DAYS=$((PMB__KEEP_DAYS + 1))

#Initialize filename vers
FILE="$(date "+%Y-%m-%d_%H_%M_%S").tar.gz"

#Create backup
log "INFO" "Backing up ${PMB__SOURCE} contents to ${FILE}"
tar -zcf - -C "${PMB__SOURCE}" . | rclone rcat "remote:/${FILE}" --config "${RCLONE_CONFIG}"

#Clean old files
log "INFO" "Cleaning older files from ${PMB__DESTINATION}..."
rclone delete remote:/ --min-age "${KEEP_DAYS}d" -v --config "${RCLONE_CONFIG}"

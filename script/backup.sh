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

RCLONE_CONFIG="/config/rclone.conf"
if [[ ! -f "${RCLONE_CONFIG}" ]]; then
  touch "${RCLONE_CONFIG}"
fi

KEEP_MINS=${PMB__KEEP_MINS}
KEEP_DAYS=${PMB__KEEP_DAYS}

#Initialize filename vers
FILE="$(date "+%Y-%m-%d_%H_%M_%S").tar.gz"

#Create backup
log "INFO" "Backing up ${PMB__SOURCE} contents to ${FILE}"
cd "${PMB__SOURCE}"
tar -zcf . | rclone rcat "${PMB__DESTINATION}/${FILE}" --config "${RCLONE_CONFIG}"

#Clean old files
log "INFO" "Cleaning older files from ${PMB__DESTINATION}..."
find ${PMB__DESTINATION} -maxdepth 1 -type f -name "*.tar.gz" -mtime "+${KEEP_DAYS}" -delete

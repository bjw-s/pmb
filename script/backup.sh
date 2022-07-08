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

if [[ ! -d "${PMB__SOURCE}" ]]; then
  echo "${PMB__SOURCE} is not a folder."
  exit 1
fi

if [[ ! -d "${PMB__DESTINATION}" ]]; then
  echo "${PMB__DESTINATION} is not a folder."
  exit 1
fi

KEEP_MINS=${PMB__KEEP_MINS}
KEEP_DAYS=${PMB__KEEP_DAYS}
KEEP_WEEKS=$(((PMB__KEEP_WEEKS * 7) + 1))
KEEP_MONTHS=$(((PMB__KEEP_MONTHS * 31) + 1))
BACKUP_SUFFIX=".tar.gz"

#Initialize dirs
mkdir -p "${PMB__DESTINATION}/last/" "${PMB__DESTINATION}/daily/" "${PMB__DESTINATION}/weekly/" "${PMB__DESTINATION}/monthly/"

#Initialize filename vers
LAST_FILENAME="$(printf "%s%s" "$(date "+%Y%m%d-%H%M%S")" "${BACKUP_SUFFIX}")"
DAILY_FILENAME="$(printf "%s%s" "$(date "+%Y%m%d")" "${BACKUP_SUFFIX}")"
WEEKLY_FILENAME="$(printf "%s%s" "$(date "+%G%V")" "${BACKUP_SUFFIX}")"
MONTHY_FILENAME="$(printf "%s%s" "$(date "+%Y%m")" "${BACKUP_SUFFIX}")"
FILE="${PMB__DESTINATION}/last/${LAST_FILENAME}"
DFILE="${PMB__DESTINATION}/daily/${DAILY_FILENAME}"
WFILE="${PMB__DESTINATION}/weekly/${WEEKLY_FILENAME}"
MFILE="${PMB__DESTINATION}/monthly/${MONTHY_FILENAME}"

#Create backup
log "INFO" "Backing up ${PMB__SOURCE} contents to ${FILE}"
tar -zcf "${FILE}" -C "${PMB__SOURCE}" .

#Copy (hardlink) for each entry
if [ -d "${FILE}" ]; then
  DFILENEW="${DFILE}-new"
  WFILENEW="${WFILE}-new"
  MFILENEW="${MFILE}-new"
  rm -rf "${DFILENEW}" "${WFILENEW}" "${MFILENEW}"
  mkdir "${DFILENEW}" "${WFILENEW}" "${MFILENEW}"
  ln -f "${FILE}/"* "${DFILENEW}/"
  ln -f "${FILE}/"* "${WFILENEW}/"
  ln -f "${FILE}/"* "${MFILENEW}/"
  rm -rf "${DFILE}" "${WFILE}" "${MFILE}"
  mv -v "${DFILENEW}" "${DFILE}"
  mv -v "${WFILENEW}" "${WFILE}"
  mv -v "${MFILENEW}" "${MFILE}"
else
  ln -f "${FILE}" "${DFILE}"
  ln -f "${FILE}" "${WFILE}"
  ln -f "${FILE}" "${MFILE}"
fi

# Update latest symlinks
ln -sf "${LAST_FILENAME}" "${PMB__DESTINATION}/last/latest${BACKUP_SUFFIX}"
ln -sf "${DAILY_FILENAME}" "${PMB__DESTINATION}/daily/latest${BACKUP_SUFFIX}"
ln -sf "${WEEKLY_FILENAME}" "${PMB__DESTINATION}/weekly/latest${BACKUP_SUFFIX}"
ln -sf "${MONTHY_FILENAME}" "${PMB__DESTINATION}/monthly/latest${BACKUP_SUFFIX}"

#Clean old files
log "INFO" "Cleaning older files from ${PMB__DESTINATION}..."
find "${PMB__DESTINATION}/last" -maxdepth 1 -mmin "+${KEEP_MINS}" -name "*${BACKUP_SUFFIX}" -exec rm -rf '{}' ';'
find "${PMB__DESTINATION}/daily" -maxdepth 1 -mtime "+${KEEP_DAYS}" -name "*${BACKUP_SUFFIX}" -exec rm -rf '{}' ';'
find "${PMB__DESTINATION}/weekly" -maxdepth 1 -mtime "+${KEEP_WEEKS}" -name "*${BACKUP_SUFFIX}" -exec rm -rf '{}' ';'
find "${PMB__DESTINATION}/monthly" -maxdepth 1 -mtime "+${KEEP_MONTHS}" -name "*${BACKUP_SUFFIX}" -exec rm -rf '{}' ';'

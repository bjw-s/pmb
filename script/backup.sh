#!/usr/bin/env bash
set -eo pipefail

KEEP_DAYS=$((PMB__KEEP_DAYS + 1))
FILE="$(date "+%Y-%m-%d_%H_%M_%S").tar.gz"

echo "INFO Backing up ${PMB__SOURCE_DIR} contents to ${FILE}"
tar -zcf - -C "${PMB__SOURCE_DIR}" . | rclone rcat "${PMB__RCLONE_REMOTE}:${PMB__RCLONE_REMOTE_PATH}${FILE}" --config "${PMB__RCLONE_CONFIG}"

echo "INFO Cleaning files older than ${PMB__KEEP_DAYS} days..."
total_backups=$(rclone size "${PMB__RCLONE_REMOTE}:${PMB__RCLONE_REMOTE_PATH}" --config "${PMB__RCLONE_CONFIG}" --json | jq --raw-output '.count')
if [[ $total_backups -gt ${PMB__KEEP_DAYS} ]]; then
  rclone delete "${PMB__RCLONE_REMOTE}:${PMB__RCLONE_REMOTE_PATH}" --min-age "${KEEP_DAYS}d" -v --config "${PMB__RCLONE_CONFIG}"
fi

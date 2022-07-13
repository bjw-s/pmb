#!/usr/bin/env bash
set -eo pipefail

export KOPIA_LOG_DIR="${PMB__DEST_DIR}/logs"
export KOPIA_CACHE_DIRECTORY="${PMB__DEST_DIR}/cache"

echo "INFO Backing up ${PMB__SRC_DIR} contents to ${PMB__DEST_DIR}"

if [[ "${PMB__FSFREEZE}" == "true" ]]; then
    echo "INFO Freezing ${PMB__SRC_DIR}"
    fsfreeze --freeze "${PMB__SRC_DIR}"
fi

mkdir -p "${PMB__DEST_DIR}"/{cache,logs,repo}

kopia repository create filesystem --path="${PMB__DEST_DIR}/repo"

kopia repository connect filesystem --path="${PMB__DEST_DIR}/repo" --override-hostname=cluster --override-username=cronjob

kopia policy set "${PMB__DEST_DIR}/repo" \
    --keep-latest "${PMB__KEEP_LATEST}" \
    --keep-hourly "${PMB__KEEP_HOURLY}" \
    --keep-daily "${PMB__KEEP_DAILY}" \
    --keep-weekly "${PMB__KEEP_WEEKLY}" \
    --keep-monthly "${PMB__KEEP_MONTHLY}" \
    --keep-annual "${PMB__KEEP_ANNUAL}"

if [[ "${PMB__COMPRESSION}" == "true" ]]; then
    kopia policy set "${PMB__DEST_DIR}/repo" --compression=zstd
fi

kopia snapshot create "${PMB__SRC_DIR}"

if [[ "${PMB__DEBUG}" == "true" ]]; then
    kopia snapshot list
    kopia content stats
fi

kopia repository disconnect

trap catch_exit EXIT

catch_exit() {
    if [[ "${PMB__FSFREEZE}" == "true" ]]; then
        echo "INFO Unfreezing ${PMB__SRC_DIR}"
        fsfreeze --unfreeze "${PMB__SRC_DIR}"
    fi
}

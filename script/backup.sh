#!/usr/bin/env bash
set -eo pipefail

if [[ "${PMB__DEBUG}" == "true" ]]; then
    set -x
fi

export KOPIA_LOG_DIR="${PMB__DEST_DIR}/logs"
export KOPIA_CACHE_DIRECTORY="${PMB__DEST_DIR}/cache"

printf "\e[1;34m%-6s\e[m\n" "Backing up ${PMB__SRC_DIR} contents to ${PMB__DEST_DIR} ..."

printf "\e[1;34m%-6s\e[m\n" "Setting up directories ..."
mkdir -p "${PMB__DEST_DIR}"/{cache,logs,repo}

if [[ ! -f "${PMB__DEST_DIR}/repo/kopia.repository.f" ]]; then
    printf "\e[1;34m%-6s\e[m\n" "Creating ${PMB__DEST_DIR}/repo kopia repository ..."
    kopia repository create filesystem --path="${PMB__DEST_DIR}/repo"
fi

printf "\e[1;34m%-6s\e[m\n" "Connecting to ${PMB__DEST_DIR}/repo kopia repository ..."
kopia repository connect filesystem --path="${PMB__DEST_DIR}/repo" --override-hostname=cluster --override-username=cronjob

printf "\e[1;34m%-6s\e[m\n" "Setting kopia retention policy ..."
kopia policy set "${PMB__DEST_DIR}/repo" \
    --keep-latest "${PMB__KEEP_LATEST}" \
    --keep-hourly "0" \
    --keep-daily "0" \
    --keep-weekly "0" \
    --keep-monthly "0" \
    --keep-annual "0"

if [[ "${PMB__COMPRESSION}" == "true" ]]; then
    printf "\e[1;34m%-6s\e[m\n" "Setting kopia compression policy ..."
    kopia policy set "${PMB__DEST_DIR}/repo" --compression=zstd
fi

if [[ "${PMB__FSFREEZE}" == "true" ]]; then
    printf "\e[1;34m%-6s\e[m\n" "Freezing ${PMB__SRC_DIR} ..."
    fsfreeze --freeze "${PMB__SRC_DIR}"
fi

printf "\e[1;34m%-6s\e[m\n" "Backing up ${PMB__SRC_DIR} ..."
kopia snapshot create "${PMB__SRC_DIR}"

if [[ "${PMB__DEBUG}" == "true" ]]; then
    printf "\e[1;34m%-6s\e[m\n" "Listing snapshots ..."
    kopia snapshot list
    printf "\e[1;34m%-6s\e[m\n" "Printing stats ..."
    kopia content stats
fi

printf "\e[1;34m%-6s\e[m\n" "Disconnecting from kopia repo ..."
kopia repository disconnect

trap catch_exit EXIT

catch_exit() {
    if [[ "${PMB__FSFREEZE}" == "true" ]]; then
        printf "\e[1;34m%-6s\e[m\n" "Unfreezing ${PMB__SRC_DIR} ..."
        fsfreeze --unfreeze "${PMB__SRC_DIR}"
    fi
}

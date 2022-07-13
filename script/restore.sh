#!/usr/bin/env bash
set -eo pipefail

export KOPIA_LOG_DIR="${PMB__DEST_DIR}/logs"
export KOPIA_CACHE_DIRECTORY="${PMB__DEST_DIR}/cache"

echo "INFO Restoring ${PMB__DEST_DIR} contents to ${PMB__SRC_DIR}"

flux -n "${PMB__NAMESPACE}" suspend helmrelease "${PMB__HELMRELEASE}"

kubectl -n "${PMB__NAMESPACE}" scale "${PMB__CONTROLLER}" "${PMB__HELMRELEASE}" --replicas 0

kopia repository connect filesystem --path="${PMB__DEST_DIR}/repo" --override-hostname=cluster --override-username=cronjob

rm -rf /mnt/config/{*,.*}

if [[ "${PMB_SNAPSHOT_ID}" == "latest" ]]; then
    latest_snapshot_id=$(kopia snapshot list --json | jq --raw-output '.[0] | .id')
else
    latest_snapshot_id=${PMB__SNAPSHOT_ID}
fi

kopia snapshot restore "${latest_snapshot_id}" "${PMB__SRC_DIR}"

kopia repository disconnect

flux -n "${PMB__NAMESPACE}" resume helmrelease "${PMB__HELMRELEASE}"

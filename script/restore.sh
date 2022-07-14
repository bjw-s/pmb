#!/usr/bin/env bash
set -eo pipefail

export KOPIA_LOG_DIR="${PMB__DEST_DIR}/logs"
export KOPIA_CACHE_DIRECTORY="${PMB__DEST_DIR}/cache"

echo "INFO Restoring ${PMB__DEST_DIR} contents to ${PMB__SRC_DIR}"

if [[ -n "${PMB__HELMRELEASE}" ]]; then
  echo "INFO Suspending Flux HelmRelease ${PMB__NAMESPACE}/${PMB__HELMRELEASE}."
  flux -n "${PMB__NAMESPACE}" suspend helmrelease "${PMB__HELMRELEASE}"
fi

echo "INFO Scaling ${PMB__CONTROLLER} ${PMB__NAMESPACE}/${PMB__CONTROLLER_NAME} to 0 replicas."
ORIGINAL_REPLICAS=$(kubectl -n "${PMB__NAMESPACE}" get "${PMB__CONTROLLER}" "${PMB__CONTROLLER_NAME}" -o=jsonpath='{.status.replicas}')
kubectl -n "${PMB__NAMESPACE}" scale "${PMB__CONTROLLER}" "${PMB__CONTROLLER_NAME}" --replicas 0

kopia repository connect filesystem --path="${PMB__DEST_DIR}/repo" --override-hostname=cluster --override-username=cronjob

rm -rf "${PMB__SRC_DIR:?}"/{*,.*}

if [[ "${PMB_SNAPSHOT_ID}" == "latest" ]]; then
    latest_snapshot_id=$(kopia snapshot list --json | jq --raw-output '.[0] | .id')
else
    latest_snapshot_id=${PMB__SNAPSHOT_ID}
fi

kopia snapshot restore "${latest_snapshot_id}" "${PMB__SRC_DIR}"

kopia repository disconnect

echo "INFO Scaling ${PMB__CONTROLLER} ${PMB__NAMESPACE}/${PMB__CONTROLLER_NAME} to ${ORIGINAL_REPLICAS} replicas."
kubectl -n "${PMB__NAMESPACE}" scale "${PMB__CONTROLLER}" "${PMB__CONTROLLER_NAME}" --replicas "${ORIGINAL_REPLICAS}"

if [[ -n "${PMB__HELMRELEASE}" ]]; then
  echo "INFO Resuming Flux HelmRelease ${PMB__NAMESPACE}/${PMB__HELMRELEASE}."
  flux -n "${PMB__NAMESPACE}" resume helmrelease "${PMB__HELMRELEASE}"
fi

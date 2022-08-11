FROM ghcr.io/onedr0p/kubernetes-kubectl:1.24.3@sha256:bc89f90805c37c14c85bb785ab3d9804c5daafa34dd6d6b4d70eff34ca601779 as kubectl
FROM ghcr.io/fluxcd/flux-cli:v0.32.0@sha256:629e2f7ef2d2485ae6313dee16b60428e3e930515dede35b1825dae1be4698c6 as flux-cli
FROM docker.io/kopia/kopia:0.11.3@sha256:4b52400182b640f1d0ed4c4a61ef10eba54179fa05d3bb23d3020b4543c914f1 as kopia

FROM alpine:3.16.2@sha256:bc41182d7ef5ffc53a40b044e725193bc10142a1243f395ee852a8d9730fc2ad

# Global Env
ENV \
  PMB__ACTION="backup" \
  PMB__DEBUG="false" \
  PMB__SRC_DIR="/data/src" \
  PMB__DEST_DIR="/data/dest"

# Backup Env
ENV \
  PMB__KEEP_LATEST=7 \
  PMB__COMPRESSION="true" \
  PMB__FSFREEZE="true"

# Restore Env
ENV \
  PMB__HELMRELEASE="" \
  PMB__NAMESPACE="" \
  PMB__CONTROLLER="deployment" \
  PMB__CONTROLLER_NAME="" \
  PMB__SNAPSHOT_ID="latest"

# Kopia Env
ENV \
  KOPIA_CONFIG_PATH="/kopia/repository.config" \
  KOPIA_PERSIST_CREDENTIALS_ON_CONNECT="false" \
  KOPIA_CHECK_FOR_UPDATES="false"

WORKDIR /app

#hadolint ignore=DL3002
USER root

#hadolint ignore=DL3018,DL4006
RUN \
  apk add --no-cache \
  bash \
  ca-certificates \
  jq \
  util-linux

COPY --chmod=755 ./script/backup.sh  /app/backup.sh
COPY --chmod=755 ./script/restore.sh /app/restore.sh
COPY --chmod=755 ./entrypoint.sh     /entrypoint.sh

COPY --from=kopia      /app/kopia             /usr/local/bin/kopia
COPY --from=flux-cli   /usr/local/bin/flux    /usr/local/bin/flux
COPY --from=kubectl    /usr/local/bin/kubectl /usr/local/bin/kubectl

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENTRYPOINT [ "/entrypoint.sh" ]

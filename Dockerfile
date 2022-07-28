FROM ghcr.io/onedr0p/kubernetes-kubectl:1.24.3@sha256:d072e6a445e2339c0a715dec785e953390bea3faf8f0d5e605502b2deb14d8ca as kubectl
FROM ghcr.io/fluxcd/flux-cli:v0.31.5@sha256:5b7d6fae8417fcad9e8621a75b0dda697a9129f9fb826725af618cc9a7402929 as flux-cli
FROM docker.io/kopia/kopia:0.11.3@sha256:4b52400182b640f1d0ed4c4a61ef10eba54179fa05d3bb23d3020b4543c914f1 as kopia

FROM alpine:3.16.1@sha256:7580ece7963bfa863801466c0a488f11c86f85d9988051a9f9c68cb27f6b7872

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

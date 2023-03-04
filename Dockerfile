FROM ghcr.io/onedr0p/kubernetes-kubectl:1.25.2@sha256:9d7a9880d59feb6d32c3d29cd5e14b9e76dfb1f086d63929db0ca295a98e5b2e as kubectl
FROM ghcr.io/fluxcd/flux-cli:v0.34.0@sha256:5a408b1557fd595baa04cfbad6072854b1420d7bbbd96894a108e433750d2337 as flux-cli
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
  PMB__KEEP_HOURLY=0 \
  PMB__KEEP_DAILY=0 \
  PMB__KEEP_WEEKLY=0 \
  PMB__KEEP_MONTHLY=0 \
  PMB__KEEP_ANNUAL=0 \
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

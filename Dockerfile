FROM ghcr.io/onedr0p/kubernetes-kubectl:1.24.3@sha256:8052c670be4800135a080bc322f603ee9ae88baa316ec07c8269187a83105e22 as kubectl
FROM ghcr.io/fluxcd/flux-cli:v0.31.3@sha256:4de2714125dab504c9386ce0edb2326a483b5aa38429cc6f2cce04a6b63d5508 as flux-cli
FROM docker.io/kopia/kopia:0.11.3@sha256:4b52400182b640f1d0ed4c4a61ef10eba54179fa05d3bb23d3020b4543c914f1 as kopia

FROM alpine:3.16.0@sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c

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

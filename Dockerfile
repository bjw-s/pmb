FROM ghcr.io/onedr0p/kubernetes-kubectl:1.24.2 as kubectl
FROM ghcr.io/fluxcd/flux-cli:v0.31.3 as flux-cli
FROM docker.io/kopia/kopia:0.11.3 as kopia

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

COPY ./script/backup.sh  /app/backup.sh
COPY ./script/restore.sh /app/restore.sh
COPY ./entrypoint.sh     /entrypoint.sh

COPY --from=kopia      /app/kopia             /usr/local/bin/kopia
COPY --from=flux-cli   /usr/local/bin/flux    /usr/local/bin/flux
COPY --from=kubectl    /usr/local/bin/kubectl /usr/local/bin/kubectl

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENTRYPOINT [ "/entrypoint.sh" ]

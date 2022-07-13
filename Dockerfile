FROM alpine:3.16.0@sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG GOCRON_VERSION="v0.0.10"

ENV \
  PMB__MODE="standalone" \
  PMB__CRON_SCHEDULE="@daily" \
  PMB__CRON_HEALTHCHECK_PORT=18080 \
  PMB__SOURCE_DIR="/data/src" \
  PMB__DESTINATION_DIR="/data/dest"\
  PMB__KEEP_DAYS=7 \
  PMB__EXCLUDE_PATTERNS="./lost+found"\
  PMB__RCLONE_REMOTE="local_dir" \
  PMB__RCLONE_REMOTE_PATH="/" \
  PMB__RCLONE_CONFIG="/app/rclone.conf" \
  PMB__FSFREEZE="true"

WORKDIR /app

#hadolint ignore=DL3002
USER root

#hadolint ignore=DL3018,DL4006
RUN \
  apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  jq \
  rclone \
  tar \
  tzdata \
  util-linux \
  && \
  case "${TARGETPLATFORM}" in \
  'linux/amd64') export ARCH='amd64' ;; \
  'linux/arm64') export ARCH='arm64' ;; \
  esac \
  && curl -L https://github.com/prodrigestivill/go-cron/releases/download/${GOCRON_VERSION}/go-cron-linux-${ARCH}-static.gz | zcat > /usr/local/bin/go-cron \
  && chmod +x /usr/local/bin/go-cron \
  && mkdir -p /app \
  && chmod -R 777 /app \
  && rm -rf /tmp/*

COPY ./script/backup.sh /app/backup.sh
COPY ./entrypoint.sh /entrypoint.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENTRYPOINT [ "/entrypoint.sh" ]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$PMB__CRON_HEALTHCHECK_PORT/" || exit 1

FROM alpine:3.16.0@sha256:4ff3ca91275773af45cb4b0834e12b7eb47d1c18f770a0b151381cd227f4c253

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG GOCRON_VERSION="v0.0.10"

ENV \
  PMB__SCHEDULE="@daily" \
  PMB__HEALTHCHECK_PORT=8080 \
  PMB__SOURCE="**None**" \
  PMB__DESTINATION="**None**"\
  PMB__KEEP_DAYS=7 \
  PMB__KEEP_WEEKS=4 \
  PMB__KEEP_MONTHS=6 \
  PMB__KEEP_MINS=1440

USER root

#hadolint ignore=DL3018,DL4006
RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        tzdata \
    && \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='amd64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
    esac \
    && curl -L https://github.com/prodrigestivill/go-cron/releases/download/${GOCRON_VERSION}/go-cron-linux-${ARCH}-static.gz | zcat > /usr/local/bin/go-cron \
    && chmod +x /usr/local/bin/go-cron \
    && rm -rf \
        /tmp/* \
    && addgroup -S pmb --gid 1002 \
    && adduser -S pmb -G pmb --uid 1002 \
    && rm -rf /tmp/*

COPY ./script/backup.sh /app/backup.sh
COPY ./entrypoint.sh /entrypoint.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER pmb

ENTRYPOINT [ "/entrypoint.sh" ]

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f "http://localhost:$PMB__HEALTHCHECK_PORT/" || exit 1

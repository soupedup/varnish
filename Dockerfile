FROM golang:1.16-buster as build
RUN apt-get update && apt-get install ca-certificates git

RUN git clone https://github.com/soupedup/purgery.git /build

WORKDIR /build

RUN CGO_ENABLED=0 go build \
    -mod readonly \
    -o binary \
    .

FROM ghcr.io/emgag/varnish:6.6.0
COPY default.vcl /etc/varnish/default.vcl

COPY --from=build /build/binary /usr/local/bin/purgery
COPY --from=build /build/start.sh /usr/local/bin/start-purgery.sh

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN apt-get update \
    && apt-get install -y bc curl \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

RUN mkdir -p /etc/services.d/varnish /etc/services.d/purgery

COPY run-varnish /etc/services.d/varnish/run
COPY run-purgery /etc/services.d/purgery/run

ENTRYPOINT [ "/init" ]

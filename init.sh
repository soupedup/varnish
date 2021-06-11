#!/bin/bash

set -e

if [ -z "${VARNISH_SECRET}" ]; then
  echo "Warning: No VARNISH_SECRET supplied"
else
  echo $VARNISH_SECRET > /etc/varnish/secret
  VARNISH_SECRET_OPTION="-S /etc/varnish/secret"
fi

gomplate -f /etc/varnish/config.vcl.tpl > /etc/varnish/default.vcl

exec varnishd \
    -j unix,user=vcache \
    -F \
    -f ${VARNISH_CONFIG} \
    -s ${VARNISH_STORAGE} \
    -a ${VARNISH_LISTEN} \
    -T ${VARNISH_MANAGEMENT_LISTEN} \
#    -p workspace_client=${VARNISH_WORKSPACE_CLIENT_SIZE} \
#    -p workspace_backend=${VARNISH_WORKSPACE_BACKEND_SIZE} \
    ${VARNISH_DAEMON_OPTS} \
    ${VARNISH_SECRET_OPTION}

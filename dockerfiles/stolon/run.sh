#!/bin/bash

function setup() {
  export POD_IP=$(curl 'http://rancher-metadata/2015-12-19/self/container/primary_ip')
}

function checkdata() {
  if [[ ! -e /stolon-data ]]; then
    echo "stolon data doesn't exist, data won't be persistent!"
    mkdir /stolon-data
  fi
  chown stolon:stolon /stolon-data
}

function launchkeeper() {
  checkdata
  export STKEEPER_LISTEN_ADDRESS=$POD_IP
  export STKEEPER_PG_LISTEN_ADDRESS=$POD_IP
  su stolon -c "stolon-keeper --data-dir /stolon-data"
}

function launchsentinel() {
  export STSENTINEL_LISTEN_ADDRESS=$POD_IP
  stolon-sentinel
}

function launchproxy() {
  export STPROXY_LISTEN_ADDRESS=$POD_IP
  stolon-proxy
}

echo "start"
setup
env

if [[ "${KEEPER}" == "true" ]]; then
  launchkeeper
  exit 0
fi

if [[ "${SENTINEL}" == "true" ]]; then
  launchsentinel
  exit 0
fi

if [[ "${PROXY}" == "true" ]]; then
  launchproxy
  exit 0
fi

exit 1

#!/bin/bash
set -e

function print_help() {
    echo "Parses Yaml files with Jinja2."
    echo "Usage: `basename $0` IN OUT CONFIG"
    exit 1
}

function run_template() {
  template=$1; shift
  template_name="`basename $template`"
  
  docker run -i --rm \
    -v `realpath $IN`:/data \
    -e TEMPLATE=$template_name \
    -e "PGID=$(id -g)" -e "PUID=$(id -u)" \
    pinterb/jinja2:0.0.16 "${VARS[@]}"
}

if [ $# -ne 3 ]; then
  print_help
fi

IN=$1; shift

OUT=$1; shift

source $1; shift

REPOSITORY=erwinnttdata
NAME=merge-yaml
VERSION=latest

FILES=( fluentd-es-config-cm.yaml fluentd-es-endpoint.yaml fluentd-es-ds.yaml fluentd-es-grok-cm.yaml fluentd-es-svc.yaml fluentd-es-templates-cm.yaml )

VARS=( "pods_index_name=$PODS_INDEX_NAME" "systemd_index_name=$SYSTEMD_INDEX_NAME"     "es_cluster_addresses=$ES_CLUSTER_ADDRESSES" )

mkdir -p "$OUT"

for f in "${FILES[@]}"; do
  echo "Parse $f ..."
  run_template $IN/$f > $OUT/$f
done

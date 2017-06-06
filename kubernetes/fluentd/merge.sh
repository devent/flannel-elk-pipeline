#!/bin/bash
set -e

function print_help() {
    echo "Merges Yaml files with Yamlreader."
    echo "Usage: `basename $0` ENV OUT"
    echo "Example: `basename $0` ams01 out"
    exit 1
}

function run_yamlreader() {
  docker run --rm \
    -v "$WORK_DIR:/work" \
    $REPOSITORY/$NAME:$VERSION \
    yamlreader "$@"
}

ENV=$1; shift
if [ -z "$ENV" ]; then
  print_help
fi

OUT=$1; shift
if [ -z "$ENV" ]; then
  print_help
fi

REPOSITORY=erwinnttdata
NAME=merge-yaml
VERSION=latest
WORK_DIR=$(realpath .)

FILES=( fluentd-es-config-cm.yaml fluentd-es-endpoint.yaml fluentd-es-ds.yaml fluentd-es-grok-cm.yaml fluentd-es-svc.yaml fluentd-es-templates-cm.yaml )

mkdir -p "$OUT"

for f in "${FILES[@]}"; do
  echo "Merge $f ..."
  run_yamlreader --width 400 basis/$f $ENV/$f > $OUT/$f
done

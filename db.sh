#!/bin/bash
set -euxo pipefail

container_id="$(docker run --rm --detach \
  --env POSTGRES_HOST_AUTH_METHOD=trust \
  --publish 5432:5432 \
  postgis/postgis:16-3.4-alpine)"
function cleanup() {
    docker kill "$container_id"
}
trap cleanup EXIT

while ! pg_isready --host=localhost --user=postgres; do
  sleep 1s
done

sleep infinity

#!/usr/bin/env bash

set -e

REPO_PATH="$(git rev-parse --show-toplevel)"

. "${REPO_PATH}/deploy/functions/graphql.sh"

hook::hasura_curl() {
  local QUERY
  QUERY="$1"
  curl -s \
       --connect-timeout 10 \
       --max-time 15 \
       -w "-%{http_code}\n" \
       -H "Content-Type: application/json" \
       -H "x-hasura-admin-secret: ${HASURA_API_KEY}" \
       -X POST ${HASURA_ENDPOINT} \
       -d "${QUERY}"
}

hook::update_hasura() {
  local QUERY
  local RESPONSE
  local i
  QUERY="$1"
  i=0

  sleep $[ ( $RANDOM % 5 )  + 1 ]s
  RESPONSE=$(hook::hasura_curl "${QUERY}")

  echo "RESPONSE:${RESPONSE}"

  until [[ "$(echo ${RESPONSE} | sed 's/.*-//g')" = "200" && ! -n "$(echo ${RESPONSE} | grep errors)" ]]; do
    if [[ $i == 3 ]]; then
      exit 1
    fi
    RESPONSE=$(hook::hasura_curl "${QUERY}")
    ((i=i+1))
    sleep 5s
  done
}

push_readme() {
  local -r image_full_path="${1}"
  local -r image="${2}"
  
  docker-pushrm ${image} -f ${image_full_path}/README.md
}

run_publish_image() {
  local -r image_path="${1:?missing_chart_name}"
  local -r image_name="$(echo ${image_path} | sed 's/.*\///g')"
  local -r image_full_path="$(git rev-parse --show-toplevel)"/"${image_path}"
  local -r image_repo="$(jq -r '.repository.name' globals/main.json)"
  local image_tag="$(jq -r '.image.tag' ${image_full_path}/metadata.json)"
  local interpreter_version
  local image
  local HASURA_QUERY
  local packages

  j2 -f json ${image_full_path}/dockerfile.j2 ${image_full_path}/metadata.json -o ./Dockerfile
  cat test/test.sh ${image_full_path}/test.sh >> test/run_test.sh

  # Login into Docker repository
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

  for interpreter in $(jq -r '.interpreters[]' ${image_full_path}/metadata.json); do
    echo "interpreter: ${interpreter}"
    interpreter_version=$(echo "${interpreter}" | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
    image="${image_repo}/${image_name}:${image_tag}-${interpreter}"
    packages="$(jq '. | with_entries(select(.key|contains("packages")))' ${image_full_path}/metadata.json)"
    docker inspect ${image} > /dev/null 2>&1 || \
      docker build \
        --build-arg INTERPRETER=${interpreter} \
        --build-arg INTERPRETER_VERSION=${interpreter_version} \
        -t ${image} .
    docker push ${image}

    HASURA_QUERY=$(jo query="${HASURA_UPSERT_DOCKER_IMAGE}" \
                    variables="$(jo repo="${image_repo}/${image_name}" \
                                    name="${image_name}" \
                                    tag="${image_tag}-${interpreter}" \
                                    interpreter="${interpreter/${interpreter_version}}" \
                                    metadata="${packages}")")

    HASURA_QUERY=$(echo ${HASURA_QUERY} | jq --arg interpreterVersion "${interpreter_version}" '.variables += {"interpreterVersion":$interpreterVersion}')

    hook::update_hasura "${HASURA_QUERY}"
  done

  push_readme "${image_full_path}" "${image_repo}/${image_name}"
}

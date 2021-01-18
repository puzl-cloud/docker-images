#!/usr/bin/env bash

REPO_PATH="$(git rev-parse --show-toplevel)"

. "${REPO_PATH}/deploy/functions/graphql.sh"

hook::hasura_curl() {
  local QUERY
  QUERY="${1}"
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
  QUERY="${1}"
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

function docker_tag_exists() {
    image="${1}"
    tag="${2}"
    curl \
      --connect-timeout 10 \
      --max-time 15 \
      --silent \
      -f \
      --head \
      -lL "https://hub.docker.com/v2/repositories/${image}/tags/${tag}/" > /dev/null
}

push_readme() {
  local -r image="${1}"
  local -r image_full_path="${2}"
  
  docker-pushrm ${image} -f ${image_full_path}/README.md
}

update_db() {
  local -r repo_path="${1}"
  local -r branch="${2}"
  local -r image_repo="$(jq -r '.repository.name' ${repo_path}/globals/main.json)"
  local HASURA_QUERY=$(jo query="${HASURA_UPSERT_DOCKER_IMAGE}" \
                          variables="$(jo images="$(jo -a </dev/null)")")

  # Login into Docker repository
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

  for image_full_path in ${repo_path}/images/*; do
    local image_name="$(echo ${image_full_path} | sed 's/.*\///g')"
    local repo="${image_repo}/${image_name}"
    if [[ "$(jq -r '.version' ${image_full_path}/metadata.json)" == "null" ]]; then
      local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)"
    else
      local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)-g$(cat ${repo_path}/globals/version)-$(jq -r '.version' ${image_full_path}/metadata.json)"
    fi
    local icon_url="$(jq -r '.iconUrl' ${image_full_path}/metadata.json)"
    local description="$(jq -r '.description' ${image_full_path}/metadata.json)"
    local enable_img="$(jq -r '.enable' ${image_full_path}/metadata.json)"
    local metadata="$(cat ${image_full_path}/metadata.json)"
    local IMAGE_OBJECT=$(jo repo="${repo}" \
                        name="${image_name}" \
                        metadata="${metadata}")
    
    if [[ "${icon_url}" != "null" ]]; then
      IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg icon "${icon_url}" '. += {"icon":$icon}')
    fi
    if [[ "${description}" != "null" ]]; then
      IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg description "${description}" '. += {"description":$description}')
    fi
    if [[ "${enable_img}" != "null" ]]; then
      IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq  --argjson enable_img ${enable_img} '. += {"enable":$enable_img}')
    fi
    if jq -r '.interpreters[]' ${image_full_path}/metadata.json > /dev/null 2>&1; then
      for interpreter in $(jq -r '.interpreters[]' ${image_full_path}/metadata.json); do
        interpreter_version=$(echo "${interpreter}" | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
        tag="${image_tag}-${interpreter}"
        IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg tag "${tag}" '. += {"tag":$tag}')
        IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg interpreter "${interpreter/${interpreter_version}}" '. += {"interpreter":$interpreter}')
        IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg interpreterVersion "${interpreter_version}" '. += {"interpreterVersion":$interpreterVersion}')
        if docker_tag_exists "${repo}" "${tag}"; then
          HASURA_QUERY=$(echo ${HASURA_QUERY} | jq ".variables.images[.variables.images | length] |= . + ${IMAGE_OBJECT}")
          if [[ "${branch}" == "master" ]]; then
            push_readme "${repo}" "${image_full_path}"
          fi
        else 
          echo "Build and push ${repo}:${tag}"
          exit 1
        fi
      done
    else
      IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg tag "${image_tag}" '. += {"tag":$tag}')
      if docker_tag_exists "${repo}" "${image_tag}"; then
        HASURA_QUERY=$(echo ${HASURA_QUERY} | jq ".variables.images[.variables.images | length] |= . + ${IMAGE_OBJECT}")
        if [[ "${branch}" == "master" ]]; then
          push_readme "${repo}" "${image_full_path}"
        fi
      else
        echo "Build and push ${repo}:${image_tag}"
        exit 1
      fi
    fi
  done
  
  hook::update_hasura "${HASURA_QUERY}"
}

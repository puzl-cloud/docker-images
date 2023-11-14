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

function harbor_tag_exists() {
    # Replace this with your Harbor domain
    local HARBOR_DOMAIN="registry.puzl.cloud"
    
    local image="${1}"
    local tag="${2}"
    local username="${PUZL_REGISTRY_USER}"  # Harbor registry username
    local password="${PUZL_REGISTRY_PASSWORD}"  # Harbor registry password

    # Get token
    local token=$(curl -s -u "${username}:${password}" -k "https://${HARBOR_DOMAIN}/service/token?service=harbor-registry&scope=repository:${image}:pull" | jq -r .token)

    # Check if tag exists
    if curl --connect-timeout 10 --max-time 15 --silent -f --head -H "Authorization: Bearer $token" -lL "https://${HARBOR_DOMAIN}/v2/${image}/manifests/${tag}" > /dev/null; then
        return 0
    else
        return 1
    fi
}

function update_hasura_and_push_readme() {
    local repo="${1}"
    local image_full_path="${2}"
    local current_hasura_query="${3}"
    local image_object="${4}"

    local hasura_query=$(echo "${current_hasura_query}" | jq ".variables.images[.variables.images | length] |= . + ${image_object}")

    echo "${hasura_query}"
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

  for image_full_path in $(find images/* -maxdepth 2 -type d); do
    if [ ! -f ${image_full_path}/metadata.json ]; then
      continue
    fi
    echo ${image_full_path}
    if [[ "$(jq -r '.name' ${image_full_path}/metadata.json)" == "null" ]]; then
      echo "Error: Empty image name"
      exit 1
    else
      local image_name="$(jq -r '.name' ${image_full_path}/metadata.json)"
    fi
    if [[ "$(jq -r '.version' ${image_full_path}/metadata.json)" == "null" ]]; then
      local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)"
    else
      local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)-g$(cat ${repo_path}/globals/version)-$(jq -r '.version' ${image_full_path}/metadata.json)"
    fi
    if [[ "${image_tag}" =~ cuda11.8 ]]; then
      local repo="registry.puzl.cloud/library/${image_name}"
      local image="library/${image_name}"
      local readme_repo="${image_repo}/${image_name}"
    else
      local repo="${image_repo}/${image_name}"
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
        if [[ "${repo}" =~ registry.puzl.cloud ]]; then
          if harbor_tag_exists "${image}" "${tag}"; then
            HASURA_QUERY=$(update_hasura_and_push_readme "${repo}" "${image_full_path}" "${HASURA_QUERY}" "${IMAGE_OBJECT}")
            if [[ "${branch}" == "master" ]]; then
              push_readme "${readme_repo}" "${image_full_path}"
            fi
          else 
            echo "Build and push ${repo}:${tag}"
            exit 1
          fi
        else 
          if docker_tag_exists "${repo}" "${tag}"; then
            HASURA_QUERY=$(update_hasura_and_push_readme "${repo}" "${image_full_path}" "${HASURA_QUERY}" "${IMAGE_OBJECT}")
            if [[ "${branch}" == "master" ]]; then
              push_readme "${repo}" "${image_full_path}"
            fi
          else 
            echo "Build and push ${repo}:${tag}"
            exit 1
          fi
        fi
      done
    else
      IMAGE_OBJECT=$(echo ${IMAGE_OBJECT} | jq --arg tag "${image_tag}" '. += {"tag":$tag}')
      if [[ "${repo}" =~ registry.puzl.cloud ]]; then
        if harbor_tag_exists "${image}" "${image_tag}"; then
          HASURA_QUERY=$(update_hasura_and_push_readme "${repo}" "${image_full_path}" "${HASURA_QUERY}" "${IMAGE_OBJECT}")
          if [[ "${branch}" == "master" ]]; then
            push_readme "${readme_repo}" "${image_full_path}"
          fi
        else 
          echo "Build and push ${repo}:${image_tag}"
          exit 1
        fi
      else 
        if docker_tag_exists "${repo}" "${image_tag}"; then
          HASURA_QUERY=$(update_hasura_and_push_readme "${repo}" "${image_full_path}" "${HASURA_QUERY}" "${IMAGE_OBJECT}")
          if [[ "${branch}" == "master" ]]; then
            push_readme "${repo}" "${image_full_path}"
          fi
        else
          echo "${image_full_path}"
          echo "Build and push ${repo}:${image_tag}"
          exit 1
          fi
        fi
    fi
  done
  
  hook::update_hasura "${HASURA_QUERY}"
  #echo ${HASURA_QUERY}
}

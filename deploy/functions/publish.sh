#!/usr/bin/env bash

set -e

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

run_publish_image() {
  local -r image_path="${1:?missing_chart_name}"
  local -r image_name="$(echo ${image_path} | sed 's/.*\///g')"
  local -r image_full_path="$(git rev-parse --show-toplevel)"/"${image_path}"
  local -r image_repo="$(jq -r '.repository.name' globals/main.json)"
  if [[ "$(jq -r '.version' ${image_full_path}/metadata.json)" == "null" ]]; then
    local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)"
  else
    local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)-g$(cat ${repo_path}/globals/version)-$(jq -r '.version' ${image_full_path}/metadata.json)"
  fi
  local interpreter_version
  local image

  j2 -f json ${image_full_path}/dockerfile.j2 ${image_full_path}/metadata.json -o ./Dockerfile

  # Login into Docker repository
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin

  if jq -r '.interpreters[]' ${image_full_path}/metadata.json > /dev/null 2>&1; then
    for interpreter in $(jq -r '.interpreters[]' ${image_full_path}/metadata.json); do
      echo "interpreter: ${interpreter}"
      if docker_tag_exists "${image_repo}/${image_name}" "${image_tag}-${interpreter}"; then
        echo "Tag ${image_tag}-${interpreter} in image ${image_repo}/${image_name} already exist. Aborted!"
        exit 1
      fi
      interpreter_version=$(echo "${interpreter}" | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
      image="${image_repo}/${image_name}:${image_tag}-${interpreter}"
      docker inspect ${image} > /dev/null 2>&1 || \
        docker build \
          --build-arg INTERPRETER=${interpreter} \
          --build-arg INTERPRETER_VERSION=${interpreter_version} \
          -t ${image} .
      docker push ${image}
      docker rmi --force ${image}
    done
  else
    image="${image_repo}/${image_name}:${image_tag}"
    docker inspect ${image} > /dev/null 2>&1 || \
      docker build \
        -t ${image} .
    docker push ${image}
    docker rmi --force ${image}
  fi
}

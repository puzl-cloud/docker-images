#!/usr/bin/env bash

set -e

run_docker_image_test() {
  local -r image_path="${1:?missing_chart_name}"
  local -r image_name="$(echo ${image_path} | sed 's/.*\///g')"
  local -r image_full_path="$(git rev-parse --show-toplevel)"/"${image_path}"
  local -r image_repo="$(jq -r '.repository.name' globals/main.json)"
  if [[ "$(jq -r '.version' ${image_full_path}/metadata.json)" == "null" ]]; then
    local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)"
  else
    local image_tag="$(jq -r '.image.tagPrefix' ${image_full_path}/metadata.json)-g$(cat ${repo_path}/globals/version)-$(jq -r '.version' ${image_full_path}/metadata.json)"
  fi
  local test_failed=0
  local interpreter_version
  local image

  j2 -f json ${image_full_path}/dockerfile.j2 ${image_full_path}/metadata.json -o ./Dockerfile
  cat ${image_full_path}/test.sh > globals/run_test.sh

  if jq -r '.interpreters[]' ${image_full_path}/metadata.json > /dev/null 2>&1; then
    for interpreter in $(jq -r '.interpreters[]' ${image_full_path}/metadata.json); do
      echo "interpreter: ${interpreter}"
      interpreter_version=$(echo "${interpreter}" | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
      image="${image_repo}/${image_name}:${image_tag}-${interpreter}"
      yq w -i globals/docker-compose.test.yml services.sut.image ${image}
      docker-compose \
        -f globals/docker-compose.test.yml \
        build \
        --build-arg INTERPRETER=${interpreter} \
        --build-arg INTERPRETER_VERSION=${interpreter_version}

      printf '\033\033[0;34m- Running docker image test %s \n\033[0m' "$image_name-${interpreter}"
      if ! docker-compose -f globals/docker-compose.test.yml up --no-build; then
        printf '\033[0;31m\U0001F6AB docker image test %s failed.\n\n\033[0m' "$image_name-${interpreter}"
        test_failed=1
        docker-compose -f globals/docker-compose.test.yml down
        break
      fi

      docker-compose -f globals/docker-compose.test.yml down

    done
  else
    image="${image_repo}/${image_name}:${image_tag}"
    yq w -i globals/docker-compose.test.yml services.sut.image ${image}
    docker-compose \
      -f globals/docker-compose.test.yml \
      build

    printf '\033\033[0;34m- Running docker image test %s \n\033[0m' "$image_name"
    if ! docker-compose -f globals/docker-compose.test.yml up --no-build; then
      printf '\033[0;31m\U0001F6AB docker image test %s failed.\n\n\033[0m' "$image_name"
      test_failed=1
      docker-compose -f globals/docker-compose.test.yml down
      break
    fi
  fi

  rm ./Dockerfile globals/run_test.sh

  if [[ "$test_failed" = "1" ]]; then
    false
  else
    printf '\033[0;32m\U00002705 docker image test %s\n\n\033[0m' "$image_name-${interpreter}"
    true
  fi
}

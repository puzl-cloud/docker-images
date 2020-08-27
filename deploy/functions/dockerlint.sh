#!/usr/bin/env bash

run_docker_lint() {
  local -r image_path="${1:?missing_chart_name}"
  local -r image_full_path="$(git rev-parse --show-toplevel)"/"$image_path"
  local test_failed=0

  j2 -f json ${image_full_path}/dockerfile.j2 ${image_full_path}/metadata.json -o ./Dockerfile

  printf '\033\033[0;34m- Running dockerfile lint in %s \n\033[0m' "$image_path"
  if ! hadolint ./Dockerfile >> /dev/null; then
    printf '\033[0;31m\U0001F6AB dockerfile lint %s failed.\n\n\033[0m' "$image_path"
    test_failed=1
  fi

  rm ./Dockerfile

  if [[ "$test_failed" = "1" ]]; then
    false
  else
    printf '\033[0;32m\U00002705 dockerfile lint %s\n\n\033[0m' "$image_path"
    true
  fi
}

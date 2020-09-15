#!/usr/bin/env bash

repo_path="$(git rev-parse --show-toplevel)"
echo "repo_path: ${repo_path}"
origin_commit="$(git rev-parse --short HEAD)"
echo "origin_commit: ${origin_commit}"
files_to_push="$(git diff --name-only ${origin_commit}^)"
echo "files_to_push: ${files_to_push}"

. "${repo_path}/deploy/functions/dockerlint.sh"
. "${repo_path}/deploy/functions/dockertest.sh"
. "${repo_path}/deploy/functions/output.sh"

for image_path in $( cut -d'/' -f1,2 <<< "${files_to_push}" | uniq ); do
  if [[ $image_path = images/* ]]; then
    skip_test=$(jq -r '.skipTests' $image_path/metadata.json)
    if [[ "${skip_test}" == "false" ]]; then
      printf '\033[01;33mValidating %s with Dockerfile lint:\n\033[0m' "$image_path"
      if ! run_docker_lint "$image_path"; then
        output "1" "Dockerfile lint"
      else
        output "0" "Dockerfile lint"
      fi
      printf '\033[01;33mRun docker image test in %s:\n\033[0m' "$image_path"
      if ! run_docker_image_test "$image_path"; then
        output "1" "Docker image test"
      else
        output "0" "Docker image test"
      fi
    fi
  fi
done

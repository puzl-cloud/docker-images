#!/usr/bin/env bash

repo_path="$(git rev-parse --show-toplevel)"
echo "repo_path: ${repo_path}"
origin_commit="$(git rev-parse --short HEAD)"
echo "origin_commit: ${origin_commit}"
files_to_push="$(git diff --name-only ${origin_commit}^)"
echo "files_to_push: ${files_to_push}"

. "${repo_path}/deploy/functions/publish.sh"

for image_path in $( echo "${files_to_push}"| sed 's#/[^/]*$##' | uniq ); do
  if [[ ${image_path} = images/* ]]; then
    run_publish_image "${image_path}"
  fi
done

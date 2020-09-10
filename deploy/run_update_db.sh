#!/usr/bin/env bash

local -r branch="${1}"

repo_path="$(git rev-parse --show-toplevel)"
echo "repo_path: ${repo_path}"

. "${repo_path}/deploy/functions/update_db.sh"

update_db "${repo_path}" "${branch}"
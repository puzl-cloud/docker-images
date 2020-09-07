#!/usr/bin/env bash

repo_path="$(git rev-parse --show-toplevel)"
echo "repo_path: ${repo_path}"

. "${repo_path}/deploy/functions/update_db.sh"

update_db "${repo_path}"
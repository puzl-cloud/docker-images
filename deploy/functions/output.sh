#!/usr/bin/env bash

output() {
  local STATUS_CODE
  local TEST_NAME
  STATUS_CODE="${1}"
  TEST_NAME="${2}"

  if [[ "${STATUS_CODE}" = "1" ]]; then
    printf "\033[0;31m\U0001F6AB ${TEST_NAME} failed.\n\n\033[0m"
    exit 1
  else
    printf "\033[0;32m\U00002705 ${TEST_NAME} succeeded.\n\n\033[0m"
  fi  
}

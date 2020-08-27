#!/bin/bash

set -e

declare -a INTERPRETERS

INTERPRETERS=($1)
REPO="$2"
NAME="$3"
TAG="$4"

HASURA_UPSERT_DOCKER_IMAGE='mutation upsertDockerImage(
  $repo: String!,
  $name: String!,
  $tag: String!,
  $interpreter: String,
  $interpreterVersion: String
){
  insert_resources_dockerImages(
    objects: {
      repo: $repo,
      name: $name,
      tag: $tag,
      interpreter: $interpreter,
      interpreterVersion: $interpreterVersion
    },
    on_conflict: {
      constraint: dockerImages_pkey,
      update_columns: [repo, tag, interpreter, interpreterVersion]
    }
  ){
    affected_rows
  }
}'


hook::curl() {
  QUERY="$1"
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
  QUERY="$1"

  RESPONSE=$(hook::curl "${QUERY}")
  if [[ "$(echo ${RESPONSE} | sed 's/.*-//g')" = "200" && ! -n "$(echo ${RESPONSE} | grep errors)" ]]; then
    echo "${RESPONSE}"
  else
    echo "${QUERY}"
    echo "${RESPONSE}"
    exit 1
  fi
}

for i in "${INTERPRETERS[@]}"; do
  INTERPRETER="${i}"
  echo ${INTERPRETER}
  INTERPRETER_VERSION=$(echo "${i}" | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')
  echo ${INTERPRETER_VERSION}
  TAG_PATCH=$(echo ${TAG} | sed "s/{{INTERPRETER}}/${INTERPRETER}/g")
  echo ${TAG_PATCH}
  docker build \
    --build-arg INTERPRETER=$INTERPRETER \
    --build-arg INTERPRETER_VERSION=${INTERPRETER/python} \
    -t ${REPO}/${NAME}:${TAG_PATCH} .
  docker push ${REPO}/${NAME}:${TAG_PATCH}

  INTERPRETER=$(echo ${INTERPRETER} | sed "s/${INTERPRETER_VERSION}//g")
  HASURA_QUERY=$(jo -p query="${HASURA_UPSERT_DOCKER_IMAGE}" \
                       variables=$(jo repo="${REPO}/${NAME}" \
                         name="${NAME}" \
                         tag="${TAG_PATCH}" \
                         interpreter="${INTERPRETER}") \
                 operationName=upsertDockerImage)
  HASURA_QUERY=$(echo ${HASURA_QUERY} | jq --arg interpreterVersion "${INTERPRETER_VERSION}" '.variables += {"interpreterVersion":$interpreterVersion}')

  hook::update_hasura "${HASURA_QUERY}"
done

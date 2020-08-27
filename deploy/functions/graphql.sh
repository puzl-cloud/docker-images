HASURA_UPSERT_DOCKER_IMAGE='mutation upsertDockerImage(
  $repo: String!,
  $name: String!,
  $tag: String!,
  $interpreter: String,
  $interpreterVersion: String,
  $metadata: jsonb!
){
  insert_resources_dockerImages(
    objects: {
      repo: $repo,
      name: $name,
      tag: $tag,
      interpreter: $interpreter,
      interpreterVersion: $interpreterVersion,
      metadata: $metadata
    },
    on_conflict: {
      constraint: dockerImages_pkey,
      update_columns: [repo, tag, interpreter, interpreterVersion, metadata]
    }
  ){
    affected_rows
  }
}'

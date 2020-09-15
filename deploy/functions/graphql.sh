HASURA_UPSERT_DOCKER_IMAGE='mutation updateDockerImagesTable(
  $images: [resources_dockerImages_insert_input!]!
){
  # Delete all old Docker images
  delete_resources_dockerImages(
    where: {repo: {_is_null: false}}
  ){
    affected_rows
  }
  # Insert all new Docker images
  insert_resources_dockerImages(
    objects: $images
  ){
    affected_rows
  }
}'

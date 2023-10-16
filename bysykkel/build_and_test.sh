#! /bin/bash
echo "Building image ..."
IMAGE_NAME="bysykkel"
IMAGE_TAG="latest"
docker build \
  --tag ${IMAGE_NAME}:${IMAGE_TAG} .
echo "Image ${IMAGE_NAME}:${IMAGE_TAG} successfully built!"

echo "Executing container structure test..."
docker container run --rm --interactive \
  --volume "${PWD}"/tests/test.yml:/tests.yml:ro \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  gcr.io/gcp-runtimes/container-structure-test:v1.15.0 test \
  --image ${IMAGE_NAME}:${IMAGE_TAG} \
  --config tests.yml
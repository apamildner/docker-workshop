#! /bin/bash
echo "Building image ..."
IMAGE_NAME="bysykkel"
IMAGE_TAG="latest"
docker buildx build --platform linux/arm64/v8 \
  --tag ${IMAGE_NAME}:${IMAGE_TAG} .
echo "Image ${IMAGE_NAME}:${IMAGE_TAG} successfully built!"
#!/bin/sh

docker buildx build --push --platform linux/arm64/v8,linux/amd64 \
  --tag stonedu/sonarqube:8.9.6-community \
  --build-arg SONARQUBE_VERSION=8.9.6.50800 \
  --build-arg SONARQUBE_ZIP_URL=https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip \
  .


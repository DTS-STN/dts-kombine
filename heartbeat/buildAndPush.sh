#!/bin/bash
VERSION=$(cat VERSION)
docker build -t mtscontainers.azurecr.io/dts-heartbeat:$VERSION .
docker build -t mtscontainers.azurecr.io/dts-heartbeat:latest .
az acr login --name mtscontainers
docker push mtscontainers.azurecr.io/dts-heartbeat:$VERSION
docker push mtscontainers.azurecr.io/dts-heartbeat:latest
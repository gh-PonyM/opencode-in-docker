#!/bin/bash
set -e

# Build script for OpenCode Docker container

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IMAGE_NAME="ubuntu-opencode"
TAG="${1:-latest}"

echo "Building OpenCode Docker image: ${IMAGE_NAME}:${TAG}"
echo "Script directory: ${SCRIPT_DIR}"

docker build \
    -t "${IMAGE_NAME}:${TAG}" \
    -f "${SCRIPT_DIR}/Dockerfile" \
    "${SCRIPT_DIR}"

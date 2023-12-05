#!/bin/bash

# Change directory to the current script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"; cd "${DIR}"

IMAGE_NAME="darkmatter-ivt:latest"

if [[ "$(docker images -q ${IMAGE_NAME} 2> /dev/null)" == "" ]]; then
	# Build the docker image
	docker build -t ${IMAGE_NAME} .
fi

# Run the compilation step
docker run --rm -it \
	-u "$(id -u):$(id -g)" \
	-v "$(pwd):/home/llvm/" \
	${IMAGE_NAME} lua src/main.lua $@

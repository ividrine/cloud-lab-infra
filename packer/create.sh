#!/bin/bash

if ! command -v packer &> /dev/null; then
    echo "Error: can't find packer"
    exit 1
fi

if [ -z "${HCLOUD_TOKEN}" ]; then
    echo "Error: HCLOUD_TOKEN environment variable is not set"
    exit 1
fi

cd "$(dirname "$0")"

packer init .
packer build .
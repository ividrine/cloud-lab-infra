#!/bin/bash
set -e

if ! command -v packer &> /dev/null; then
    echo "Error: can't find packer. Is it installed?"
    exit 1
fi

if [ -z "${HCLOUD_TOKEN}" ]; then
    echo "Error: HCLOUD_TOKEN environment variable is not set"
    echo "Try running: export HCLOUD_TOKEN=your_token_here"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

packer init .
packer build .
echo "Packer completed successfully."
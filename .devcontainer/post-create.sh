#!/bin/bash -eu
set -o pipefail

# Install Redocly CLI globally
npm install @redocly/cli -g

# Install yq
mkdir -p "${HOME}/.local/bin"
curl -sSfL -o - https://github.com/mikefarah/yq/releases/download/v4.45.1/yq_linux_amd64.tar.gz | \
    tar -zxf - -O "./yq_linux_amd64" > "${HOME}/.local/bin/yq"
chmod +x "${HOME}/.local/bin/yq"


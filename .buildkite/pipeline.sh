#!/bin/bash

set -euo pipefail

cat <<EOF
steps:
  - label: Build a Thing
    command: /bin/true
EOF

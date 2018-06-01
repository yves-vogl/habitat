#!/bin/bash

set -euo pipefail

component=${1}

HAB_STUDIO_SUP=false hab studio run "build components/${component}"

# TODO (CM): Push to Builder in a release channel
# TODO (CM): pass a release channel in as an argument / environment variable
# TODO (CM): pass an auth token in environment
# TODO (CM): Keep the HART as an artifact in Buildkite?

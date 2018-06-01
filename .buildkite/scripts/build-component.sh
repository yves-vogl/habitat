#!/bin/bash

set -euo pipefail

component=${1}

sudo hab pkg build "components/${component}"

# TODO (CM): Push to Builder in a release channel
# TODO (CM): pass a release channel in as an argument / environment variable
# TODO (CM): pass an auth token in environment
# TODO (CM): Keep the HART as an artifact in Buildkite?

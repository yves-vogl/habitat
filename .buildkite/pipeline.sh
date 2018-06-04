#!/bin/bash

set -euo pipefail

#if [[ "${BUILDKITE_TAG}" ]]; then
    # Our releases are currently triggered by the existence of a tag

    # channel="rc-${BUILDKITE_TAG}"
channel="magical-mystery-tour"
echo "--- :sparkles: Preparing for a release! :sparkles:"
buildkite-agent meta-data set "release-channel" "${channel}"
buildkite-agent pipeline upload .buildkite/release_pipeline.yaml
# else
#     echo "--- :sparkles: Preparing for a CI run! :sparkles:"
#     echo "TODO"
#     exit 1
# fi

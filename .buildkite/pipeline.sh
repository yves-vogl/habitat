#!/bin/bash

set -euo pipefail

if [[ "${FAKE_RELEASE_TAG}" || "${BUILDKITE_TAG}" ]]; then
    # Our releases are currently triggered by the existence of a tag
    echo "--- :sparkles: Preparing for a release! :sparkles:"

    if [[ "${FAKE_RELEASE_TAG}" ]]; then
        echo ":warning: Using fake release tag '${FAKE_RELEASE_TAG}' :warning:"
        channel="rc-${FAKE_RELEASE_TAG}"
    elif [[ "${BUILDKITE_TAG}" ]]; then
        echo "Using release tag '${BUILDKITE_TAG}'"
        channel="rc-${BUILDKITE_TAG}"
    fi

    echo "Release channel is '${channel}'"
    buildkite-agent meta-data set "release-channel" "${channel}"
    buildkite-agent pipeline upload .buildkite/release_pipeline.yaml
else
    echo "--- :sparkles: Preparing for a CI run! :sparkles:"
    echo "TODO"
    exit 1
fi

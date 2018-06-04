#!/bin/bash

# At the end of the release pipeline, we should destroy the temporary
# release pipeline we were using. This needs to happen after a
# successful release, just to clean up, but also after a failed
# process, in order to remove potentially buggy packages from the
# channel for the next time through.

set -euo pipefail

channel="$(buildkite-agent meta-data get release-channel)"
echo "--- Destroying release channel '${channel}'"
hab bldr channel destroy \
    --auth="${HAB_TEAM_AUTH_TOKEN}"
    --origin=core \
    "${channel}"

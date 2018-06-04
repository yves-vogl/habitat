#!/bin/bash

set -euo pipefail

# `component` should be the subdirectory name in `components` where a
# particular component code resides.
#
# e.g. `hab` for `core/hab`, `plan-build` for `core/hab-plan-build`,
# etc.
component=${1}

channel=$(buildkite-agent meta-data get "release-channel")

# TODO (CM): Extract this function to somewhere else?
import_keys() {
    echo "--- :key: Downloading 'core' public keys from Builder"
    hab origin key download core
    echo "--- :closed_lock_with_key: Downloading latest 'core' secret key from Builder"
    hab origin key download \
        --auth="${HAB_TEAM_AUTH_TOKEN}" \
        --secret \
        core
    # TODO (CM): delete the secret key later?
}
import_keys

echo "--- :zap: Cleaning up old studio, if present"
hab studio rm

echo "--- :habicat: Building components/${component}"
unset HAB_BINLINK_DIR # This is set by releng, but seems to be messing
# things up for us in the studio
export HAB_ORIGIN=core
export HAB_NONINTERACTIVE=1
HAB_BLDR_CHANNEL="${channel}" hab pkg build "components/${component}"
source results/last_build.env

case "${component}" in
    "hab")
        echo "--- :buildkite: Storing artifact ${pkg_ident}"
        buildkite-agent artifact upload "results/${pkg_artifact}"
        buildkite-agent meta-data set "hab-version" "${pkg_ident}"
        ;;
    *)
        ;;
esac

echo "--- :habicat: Uploading ${pkg_ident} to Builder in the '${channel}' channel"
hab pkg upload \
    --channel="${channel}" \
    --auth="${HAB_TEAM_AUTH_TOKEN}" \
    "results/${pkg_artifact}"

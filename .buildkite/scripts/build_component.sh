#!/bin/bash

set -euo pipefail

# TODO (CM): Extract this function to somewhere else?
import_keys() {
    echo "--- :key: Downloading 'core' public keys from Builder"
    ${hab_binary} origin key download core
    echo "--- :closed_lock_with_key: Downloading latest 'core' secret key from Builder"
    ${hab_binary} origin key download \
        --auth="${HAB_TEAM_AUTH_TOKEN}" \
        --secret \
        core
    # TODO (CM): delete the secret key later?
}

# Until we have built both a new core/hab _and_ a new core/hab-studio package, we
# should continue to use the `hab` binary provided on our Buildkite
# builders (managed by Release Engineering) (these should be the
# latest stable release, btw).
#
# Once we have bootstrapped ourselves enough, however, we should
# switch subsequent builds to use the new hab, which in turn uses the
# new studio.
set_hab_binary() {
    echo "--- :thinking_face: Determining which 'hab' binary to use"

    local hab_ident=$(buildkite-agent meta-data get hab-version)
    local studio_ident=$(buildkite-agent meta-data get studio-version)

    if [[ "${hab_ident}" && "${studio_ident}" ]]; then
        echo "Buildkite metadata found; installing new versions of 'core/hab' and 'core/hab-studio'"
        # By definition, these will be fully-qualified identifiers,
        # and thus do not require a `--channel` option. However, they
        # should be coming from the release channel, and should be the
        # same packages built previously in this same release pipeline.

        sudo hab pkg install "${hab_ident}"
        sudo hab pkg install "${studio_ident}"
        declare -g hab_binary="/hab/pkgs/${hab_ident}/bin/hab"
    else
        echo "Buildkite metadata NOT found; using previously-installed hab binary"
        declare -g hab_binary="$(which hab)"
    fi
    echo "--- :habicat: Using $(${hab_binary} --version)"
}


# This is a workaround to not being able to delete artifacts from our
# builders at the moment. Once we've built a studio in a previous
# pipeline run (that doesn't succeed), it can poison subsequent runs
# if they're on the same machine.
set_studio_binary() {
    echo "--- :thinking_face: Determining which 'hab-studio' binary to use"

    local hab_ident=$(buildkite-agent meta-data get hab-version)
    local studio_ident=$(buildkite-agent meta-data get studio-version)

    if [[ "${hab_ident}" && "${studio_ident}" ]]; then
        # use that studio ident
        declare -g studio_bin="/hab/pkgs/${studio_ident}/bin/hab-studio"
        declare -g new_studio="true"
        # We will have already installed the studio above
    else
        # use the old ident... this is fragile right now, obviously
        # TODO (CM): Could just install core/hab-studio from stable
        # and sort out what the full ident is.
        studio_ident="core/hab-studio/0.56.0/20180530235913"
        declare -g studio_bin="/hab/pkgs/${studio_ident}/bin/hab-studio"
        sudo hab pkg install "${studio_ident}"
        declare -g new_studio="false"
    fi
    echo "--- :habicat: Using '${studio_bin}'"
}

########################################################################

# TODO (CM): Consider setting HAB_NONINTERACTIVE in the top-level
# environment, instead
export HAB_NONINTERACTIVE=1

# `component` should be the subdirectory name in `components` where a
# particular component code resides.
#
# e.g. `hab` for `core/hab`, `plan-build` for `core/hab-plan-build`,
# etc.
component=${1}

channel=$(buildkite-agent meta-data get "release-channel")

# This function _must_ be called first!
set_hab_binary
set_studio_binary
import_keys


echo "--- :zap: Cleaning up old studio, if present"
HAB_STUDIO_BINARY="${studio_bin}" ${hab_binary} studio rm

echo "--- :habicat: Building components/${component}"

# The binlink dir is set by releng, but seems to be messing things up
# for us in the studio.
unset HAB_BINLINK_DIR
export HAB_ORIGIN=core

# Eww
if [[ "${new_studio}" == "true" ]]; then
    CI_OVERRIDE_CHANNEL="${channel}" HAB_STUDIO_BINARY="${studio_bin}" HAB_BLDR_CHANNEL="${channel}" ${hab_binary} pkg build "components/${component}"
else
    HAB_STUDIO_BINARY="${studio_bin}" HAB_BLDR_CHANNEL="${channel}" ${hab_binary} pkg build "components/${component}"
fi
source results/last_build.env

case "${component}" in
    "hab")
        echo "--- :buildkite: Storing artifact ${pkg_ident}"
        # buildkite-agent artifact upload "results/${pkg_artifact}"
        buildkite-agent meta-data set "hab-version" "${pkg_ident}"
        ;;
    "studio")
        echo "--- :buildkite: Recording metadata for ${pkg_ident}"
        # buildkite-agent artifact upload "results/${pkg_artifact}"
        buildkite-agent meta-data set "studio-version" "${pkg_ident}"
        ;;
    *)
        ;;
esac

echo -e "<br>* ${pkg_ident}" | buildkite-agent annotate --append --context "release-manifest"

echo "--- :habicat: Uploading ${pkg_ident} to Builder in the '${channel}' channel"
${hab_binary} pkg upload \
    --channel="${channel}" \
    --auth="${HAB_TEAM_AUTH_TOKEN}" \
    "results/${pkg_artifact}"

#!/bin/bash

set -euo pipefail

 # TODO (CM): Seriously... noninteractive

# We need to upload (but not publish) artifacts to Bintray right now.

channel=$(buildkite-agent meta-data get "release-channel")

# TODO (CM): extract set_hab_binary function to a common library and
# use it here

echo "--- :habicat: Installing core/hab-bintray-publish from '${channel}' channel"
sudo hab pkg install \
     --channel="${channel}" \
     core/hab-bintray-publish

# TODO (CM): determine artifact name for given hab identifier
#            could save this as metadata, or just save the artifact in
#            BK directly

echo "--- :habicat: Uploading core/hab to Bintray"

# TODO (CM): Continue with this approach, or just grab the artifact
# that we built out of BK?
#
# If we use `hab pkg install` we know we'll get the artifact for our
# platform.

sudo hab pkg install core/hab --channel="${channel}"

hab_artifact=$(buildkite-agent meta-data get "hab-artifact")


# We upload to the stable channel, but we don't *publish* until
# later.
#
# -s = skip publishing
# -r = the repository to upload to
HAB_BLDR_CHANNEL=${channel} \
                hab pkg exec core/hab-bintray-publish \
                publish-hab \
                -s \
                -r stable \
                "/hab/cache/artifacts/${hab_artifact}"

# TODO (CM): Surface the Bintray download URL as an annotation
echo "--- :habicat: Uploading core/hab-studio to Bintray"

# again, override just for backline
HAB_BLDR_CHANNEL="${channel}" \
CI_OVERRIDE_CHANNEL="${channel}" \
                hab pkg exec core/hab-bintray-publish \
                publish-studio \
                -r stable

# The logic for the creation of this image is spread out over soooo
# many places :/
source results/last_image.env
echo <<EOF | buildkite-agent annotate --style=success --context=docker-studio
<h3>Docker Studio Image</h3>
<ul>
  <li><code>${docker_image}:${docker_image_version}</code></li>
  <li><code>${docker_image}:${docker_image_short_version}</code></li>
  <li><code>${docker_image}:latest</code></li>
</ul>
EOF

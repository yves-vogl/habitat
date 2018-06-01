#!/bin/bash

set -euo pipefail

component=${1}

hab pkg build "components/${component}"

# TODO (CM): Push to Builder in a release channel
# TODO (CM): pass a release channel in as an argument / environment variable
# TODO (CM): pass an auth token in environment

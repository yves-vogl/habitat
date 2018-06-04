#!/bin/bash

set -euo pipefail






component=${1}



import_key() {
    echo "--- :closed_lock_with_key: Importing origin secret key"
cat << EOF > core.sig.key
SIG-SEC-1
core-20160810182414

${HAB_ORIGIN_KEY}
EOF

if [ -n "$HAB_ORIGIN_KEY" ]; then
    hab origin key import < ./core.sig.key
fi
# todo else ERROR
rm ./core.sig.key
}

import_key



# echo "--- Debugging"
# echo "PWD: $(pwd)"
# echo "ls: $(ls -alh)"a
# echo ""
# echo "/hab/bin: $(ls -alh /hab/bin)"
# echo "/hab/bin/build: $(cat /hab/bin/build)"

# set +e
# hab studio run ls -alh components/${component}
# hab studio run ls -alh /hab/bin/
# echo
# hab studio run cat /hab/bin/build
# echo

echo "--- :zap: Clean up old studio, if present"
hab studio rm

echo "--- :habicat: Build components/${component}"
unset HAB_BINLINK_DIR
HAB_NONINTERACTIVE=1 HAB_ORIGIN=core HAB_STUDIO_SUP=false hab studio run "build components/${component}"

#hab pkg build "components/${component}"

if [[ "$?" != "0" ]]; then
    cat results/logs/*.log
    exit 1
fi
# TODO (CM): Push to Builder in a release channel
# TODO (CM): pass a release channel in as an argument / environment variable
# TODO (CM): pass an auth token in environment
# TODO (CM): Keep the HART as an artifact in Buildkite?
#            Might be a good way to ensure that we've got the hab
#            version we just built
# TODO (CM): pass in an origin key and import it


# In Travis, we had to have logic for pushing depending on whether
# we're doing a release build or not. Since we can construct the
# pipeline however we want here, we can have simpler scripts

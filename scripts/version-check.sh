#!/bin/bash

COMMIT_TIMESTAMP=$(git show -s --format=%ct)

SECONDS_BETWEEN=$(($(date -u +%s) - $(date -u -d "${COMMIT_TIMESTAMP:?}" +%s)))

DAYS_SINCE=$((SECONDS_BETWEEN / 86400))

if [[ ${DAYS_SINCE} -ge 5 ]]; then
    if[[ ${FLAG_OUTDATED} -eq 1 ]]; then
	    exit 1
	fi
	export FLAG_OUTDATED=1
fi

exit 0

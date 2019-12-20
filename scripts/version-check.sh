#!/bin/bash

COMMIT_TIMESTAMP=$(git show -s --format=%ct)

SECONDS_BETWEEN=$(($(date -u +%s) - ${COMMIT_TIMESTAMP}))

DAYS_SINCE=$((SECONDS_BETWEEN / 86400))

if [[ ${DAYS_SINCE} -ge 5 ]]; then
    if [[ ${FLAG_OUTDATED} -eq 2 ]]; then
	    exit 1
	fi
	let FLAG_OUTDATED=FLAG_OUTDATED+1
fi

export FLAG_OUTDATED
exit 0

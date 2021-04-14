#!/bin/bash
set -x
set -e

# https://stackoverflow.com/questions/6245293/extract-version-number-from-file-in-shell-script/6245903
git fetch --tags
LAST_TAG=$(git describe --tags --match "[0-9\.]*" HEAD~1)
echo "Detected LAST_TAG: [$LAST_TAG]"

LAST_VERSION=$(echo $LAST_TAG | grep -o "[0-9]*\.[0-9]*\.[0-9]*")
echo "Parsed LAST_VERSION: [$LAST_VERSION]"

PARSED_VERSION=( ${LAST_VERSION//./ } )
((PARSED_VERSION[1]++))

NEXT_VERSION="${PARSED_VERSION[0]}.${PARSED_VERSION[1]}.${PARSED_VERSION[2]}"
echo "Created NEXT_VERSION: [$NEXT_VERSION]"

git tag -a $NEXT_VERSION -m "CI: Auto tagging $NEXT_VERSION" || true # make idempotent
git push --tags

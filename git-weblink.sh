#!/bin/bash
set -euo pipefail;

# gets the URL for a webpage corresponding to file
# this script incorporates code from: https://superuser.com/a/1157267
# provided by user gsinti

FILE=$1
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# construct the relative path to the repository root
GIT_DIR=$(git rev-parse --git-dir)
REPO_DIR=$(realpath "$GIT_DIR/../")
REL_PATH=$(realpath --relative-to="$REPO_DIR" "$FILE")

URL=$(git config --get remote.origin.url | sed 's/\.git//g')
URL=$(echo "$URL" | sed 's/git\@github.com:/https\:\/\/github.com\//g')

COLON_COUNT=$(echo "$URL" | grep -o ':' | wc -l)

if [[ $COLON_COUNT -eq 1 ]]; then
    if [[ "$URL" =~ https://.* ]]; then
	if [[ "$URL" =~ https://github.com* ]]; then
	    HOST="https://github.com";
	else
	    HOST=""
	fi
	REPO_URL="$URL"
    else
	HOST=$(echo "$URL" | cut -d ':' -f 1)
	REPO_NAME=$(echo "$URL" | cut -d ':' -f 2)
	URL=$(echo "$HOST" | sed 's/git\@/https\:\/\//g')
	REPO_URL="$URL/$REPO_NAME"
    fi
else
    # TODO: clean up error
    echo "$URL has multiple colons, cannot process" 
    exit 1
fi



if [[ "$HOST" =~ "https://github.com" ]]; then 
    echo "$REPO_URL/$BRANCH/blob/$BRANCH/$REL_PATH"
else
    # gitlab format
    # would this be better with /-/blob/ instead of /-/tree/? 
    echo "$REPO_URL/-/tree/$BRANCH/$REL_PATH"
fi

exit 0

#!/bin/sh

# given a sitemap file, a revision lockfile and an article name, 
# this script updates the article's revision to latest.
set -e

SCRIPTPATH=$(dirname "$0")
SITEMAP=$1
REVISION_LOCKFILE=$2
ARTICLE=$3

REVISION=$($SCRIPTPATH/get_revision.sh $REVISION_LOCKFILE 'articles' "$ARTICLE");
flock $SITEMAP -c "jq -c \"(.parts[] | .chapters[] | select(.path==\\\"$ARTICLE\\\" and .revision==\\\"latest\\\") | .revision)=\\\"$REVISION\\\"\" $SITEMAP | sponge $SITEMAP";

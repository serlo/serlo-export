#!/bin/sh

# get the revision of the article from a revision lock file.
# if it is not currently known, it the latest revision will be fetched 
# and stored in the lock file.
# Arguments: <revision_file> <section> <article name>
set -e

NAME=$(echo "$3" | sed -e "s/ /_/g")
REV_FILE="$1"
SECTION=$2

# create lockfile if not present
[ -f $REV_FILE ] || echo '{"articles": {"articles": "dummy"}, "media": {}}' > $REV_FILE;

HAS_KEY=$(flock -s $REV_FILE jq ".$SECTION | has(\"$NAME\")" $REV_FILE);

if [ $HAS_KEY != true ]; then 
    REVISION=error
    if [ $SECTION = articles ]; then
        URL_ENC=$(echo $NAME | jq -r -R @uri)
        REVISION=$(curl -qgsf "https://de.wikibooks.org/api/rest_v1/page/title/$URL_ENC" | jq ".items[0].rev")
        REVISION=$(echo "$REVISION" | grep -e "^[0-9][0-9]*$" || echo "error")
    fi
    if [ $SECTION = media ]; then
        REVISION=$(curl -Gqgsf "https://de.wikibooks.org/w/api.php" \
                        --data-urlencode "titles=File:$NAME" \
                        --data-urlencode "prop=imageinfo" \
                        --data-urlencode "iilimit=max" \
                        --data-urlencode "iiprop=url|sha1|timestamp" \
                        --data-urlencode "iistart=now" \
                        --data-urlencode "format=json" \
                        --data-urlencode "action=query" \
                       | jq -r '.query.pages."-1".imageinfo | map(.timestamp) | max')
        # revision has to start with year
        REVISION=$(echo "$REVISION" | grep -e "^[0-9][0-9]*" || echo "error")
    fi

    [ $REVISION != error ] || (>&2 echo "revision fetching failed for $NAME"! && exit 1);
    # use sponge here to keep the file at the same inode, 
    # avoiding issues with parallel access
    flock -x $REV_FILE -c "jq \".$SECTION += {\\\"$NAME\\\": \\\"$REVISION\\\"}\" $REV_FILE | sponge $REV_FILE"
else
    REVISION=$(flock -s $REV_FILE jq -r ".$SECTION.\"$NAME\"" $REV_FILE)
fi

echo $REVISION

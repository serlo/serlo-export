# get the revision of the article from a revision lock file.
# if it is not currently known, it the latest revision will be fetched 
# and stored in the lock file.
# Arguments: <revision_file> <article name>
set -e

NAME=$(sed -e "s/ /_/g" <<< "$2")
REV_FILE="$1"

# create lockfile if not present
[[ -f $REV_FILE ]] || echo '{"articles": {}, "media": {}}' > $REV_FILE;

HAS_KEY=$(flock $REV_FILE jq ".articles | has(\"$NAME\")" $REV_FILE);

if [ $HAS_KEY != true ]; then 
    URL_ENC=$(jq -r -R @uri <<< $NAME)
    REVISION=$(curl -qgsf "https://de.wikibooks.org/api/rest_v1/page/title/$URL_ENC" | jq ".items[0].rev")
    REVISION=$(grep -e "^[0-9][0-9]*$" <<< "$REVISION" || echo "error")

    [[ $REVISION != error ]] || (>&2 echo "revision fetching failed for $NAME"! && exit 1);
	flock $REV_FILE jq ".articles += {\"$NAME\": $REVISION}" $REV_FILE > $REV_FILE.new
    mv $REV_FILE.new $REV_FILE
else
    REVISION=$(flock $REV_FILE jq ".articles.\"$NAME\"" $REV_FILE)
fi

echo $REVISION

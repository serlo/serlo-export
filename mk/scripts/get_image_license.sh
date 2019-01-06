#!/bin/bash
#
# Download the license of an image from Wikimedia and do some necessary post-processing
# Arguments:
#   filename
#   revision (timestamp)

USERNAMES='{
    "Claudia4": "Claudia Renner",
    "Agnessa power": "Agnes Pauer",
    "Mattlocke2.0": "Matthias Greger",
    "Auswahlaxiom": "Autorenkollektiv „Auswahlaxiom“ (Charlotte Dietze, Matthias Paulsen, Anne Reif)",
    "Morpurgo10": "Paolo Martinoni",
    "Taschee": "Alexander Sedlmayr",
    "Ceranilo": "Caroline Pfannschmidt",
    "W.e.r.n": "Werner Fröhlich",
    "Mathpro01": "Werner Fröhlich",
    "MJ Studies": "Menuja J. (MJ Studies)",
    "JennKi": "Jenny Kilian",
    "KatharinaKircher": "Katharina Kircher",
    "Ch1nie": "Chris ShuYu Dong",
    "Sven87a": "Sven Prüfer",
    "Einhalbmvquadrat": "Ekin Köksal",
    "Griever~dewikibooks": "Akram Chawki"
}'

IMG_INFO=$(curl -Gfgqs "https://de.wikibooks.org/w/api.php" \
                --data-urlencode "titles=File:$1" \
                --data-urlencode "prop=imageinfo" \
                --data-urlencode "iiprop=user|extmetadata|url" \
                --data-urlencode "iilimit=max" \
                --data-urlencode "iiextmetadatafilter=LicenseShortName|UsageTerms|AttributionRequired|Restrictions|Artist|ImageDescription|DateTimeOriginal|Credit" \
                --data-urlencode "iistart=$2" \
                --data-urlencode "action=query" \
                --data-urlencode "format=json" \
           | jq '.query.pages."-1".imageinfo')

METADATA=$(echo $IMG_INFO | jq '.[0] | .extmetadata')

LICENSE_SHORT=$(echo $METADATA | jq -r '.LicenseShortName.value // ""')
SOURCE=$(echo $METADATA | jq -r '.Artist.value // "" | @json')

URL=

if [ $(echo $LICENSE_SHORT | jq -R 'startswith("CC")') = "true" ]
then
    if [ $(echo $LICENSE_SHORT | jq -R '. == "CC0"') = "true" ]
    then
        URL="https://creativecommons.org/publicdomain/zero/1.0/"
    else
        COMPONENTS=$(echo $LICENSE_SHORT | jq -R 'ascii_downcase | split(" ")')
        if [ "$(echo $COMPONENTS | jq 'length')" = "3" ]
        then
            URL=$(echo $COMPONENTS | jq -r '"https://creativecommons.org/licenses/" + .[1] + "/" + .[2] + "/"')
        else
            if [ $(echo $LICENSE_SHORT | jq -R 'startswith("CC-")') ]
            then
                MATCH=$(echo $LICENSE_SHORT | jq -R 'match("-[^-]*$")')
                OFFSET=$(echo $MATCH | jq '.offset')
                MODE=$(echo $LICENSE_SHORT | jq -Rr ".[:$OFFSET] | ascii_downcase")
                VERSION=$(echo $MATCH | jq -r '.string | .[1:] | ascii_downcase')
                URL=$(echo "" | jq -rR "\"https://creativecommons.org/licenses/\" + \"$MODE\" + \"/\" + \"$VERSION\" + \"/\"")
            else
                (>&2 echo Unknown license: $LICENSE_SHORT)
                URL="unknown"
            fi
        fi
    fi
elif [ "$(echo $LICENSE_SHORT | jq -Rr 'ascii_downcase')" = "public domain" ]
then
    URL="https://creativecommons.org/licenses/publicdomain/"
elif [ "$(echo $LICENSE_SHORT | jq -Rr 'ascii_downcase')" = "gfdl" ]
then
    URL="http://www.gnu.org/licenses/fdl.html"
else
    (>&2 echo Unknown license: $LICENSE_SHORT)
    URL="unknown"
fi

AUTHORS=$(echo $IMG_INFO | jq '[.[] | .user] | unique')

USAGE_TERMS=$(echo $METADATA | jq '.UsageTerms.value // ""')

USER=$(echo $IMG_INFO | jq -r '.[0] | .user')

echo "{
    \"license\": {
        \"user\": $(echo $USERNAMES | jq ".[\"$USER\"] // \"$USER\""),
        \"name\": $USAGE_TERMS,
        \"shortname\": \"$LICENSE_SHORT\",
        \"licenseurl\": \"$URL\",
        \"detailsurl\": \"https://commons.wikimedia.org/wiki/File:$1\",
        \"url\": $(echo $IMG_INFO | jq '.[0] | .url'),
        \"authors\": $(echo $AUTHORS | jq --argjson usernames "$USERNAMES" '[.[] as $author | $usernames | .[$author] // $author]'),
        \"source\": $SOURCE,
        \"filename\": \"$1\"
    }
}"

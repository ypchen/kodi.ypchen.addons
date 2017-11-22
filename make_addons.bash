#!/bin/bash

DIR_ADDONS="addons"

echo Enter directory \"${DIR_ADDONS}\"
cd "${DIR_ADDONS}" &> /dev/null
if [[ $? -ne 0 ]]; then
    echo Directory \"${DIR_ADDONS}\" not found.
    exit 1
fi

# Generate addons.xml along the process
echo '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' > ../addons.xml
echo '<addons>' >> ../addons.xml

echo Process addons
for addon in *; do
    echo -- Add-on: ${addon}
    echo ---- copy addon.xml
    cp "../../${addon}/addon.xml" "${addon}"
    version=`grep 'id="' "${addon}/addon.xml" | sed -n 's/^.*version="\(.*\)" .*$/\1/p' | cut -f 1 -d '"'`
    echo ---- obtain version: ${version}
    echo ---- go to ../..
    cd ../..
    echo ---- zip the add-on
    zip -r "${addon}-${version}.zip" "${addon}/" -x "*.git*"
    echo ---- go back
    cd -
    echo ---- move the zip
    mv "../../${addon}-${version}.zip" ${addon}
    echo ---- fill addons.xml
    awk '/<addon /{flag=1}/<\/addon>/{flag=0}flag' "${addon}/addon.xml" >> ../addons.xml
    echo '</addon>' >> ../addons.xml
done

echo '</addons>' >> ../addons.xml

echo Leave directory \"${DIR_ADDONS}\"
cd ..

echo Calculate the md5sum
md5sum addons.xml | cut -f 1 -d ' ' | tr -d '\n' > addons.xml.md5

echo Done

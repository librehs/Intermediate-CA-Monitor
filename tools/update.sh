#!/bin/bash

MONTH=$(date +%m)
YEAR=$(date +%Y)

if [ $MONTH == "01" ]
then
    LASTYEAR=$((YEAR - 1))
    LASTMONTH=12
else
    LASTYEAR=$YEAR
    if [ $MONTH -le "10" ]
    then
        LASTMONTH=0$((MONTH - 1))
    else
        LASTMONTH=$((MONTH - 1))
    fi
fi

echo "Fetching certificates for ${YEAR}/${MONTH}"
mkdir -p data/${YEAR}
wget https://ccadb-public.secure.force.com/mozilla/PublicAllIntermediateCertsCSV -O data/${YEAR}/${YEAR}-${MONTH}-ica.csv
wget https://ccadb-public.secure.force.com/mozilla/PublicAllIntermediateCertsWithPEMCSV -O data/${YEAR}/${YEAR}-${MONTH}-ica-withpem.csv
echo "Comparing difference from ${LASTYEAR}/${LASTMONTH} to ${YEAR}/${MONTH}"
LASTFILENAME="data/${LASTYEAR}/${LASTYEAR}-${LASTMONTH}-ica.csv"
if [ -f "$LASTFILENAME" ]
then
    diff $LASTFILENAME data/${YEAR}/${YEAR}-${MONTH}-ica.csv > data/${YEAR}/${YEAR}-${MONTH}-ica.diff
else
    echo "[WARN] File for last month $LASTFILENAME doesn't exist."
fi

echo "Pushing to git"
git add -A
git commit -m "Update for ${YEAR}/${MONTH}"

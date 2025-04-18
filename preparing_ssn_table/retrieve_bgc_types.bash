#!/bin/bash

bgc_types="../antismash_structures/antismash/databases/clusterblast/clusters.txt"
proteins=$1
output_file=$2

echo "accession,bgc_type" > "$output_file"

if [ ! -f "$proteins" ]; 
then
    echo "Proteins file not found: $proteins" >&2
    exit 1
fi

if [ ! -f "$bgc_types" ]; 
then
    echo "ClusterBlast txt is missing or the path is wrong" >&2
    exit 1
fi

while IFS= read -r tag || [[ -n "$tag" ]]; do
    bgc_type=$(grep "$tag" $bgc_types | cut -f4 | sort -u | tr '\n' ';' | sed 's/;$/]\n/')
    echo "$tag, [$bgc_type" >> $output_file
done < "$proteins"
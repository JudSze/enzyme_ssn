#!/bin/bash

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <accession_file.txt> <output_file.fasta>"
    exit 1
fi

ACCESSION_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [ ! -f "$ACCESSION_FILE" ]; then
    echo "Error: Accession file $ACCESSION_FILE not found."
    exit 1
fi

# Create/clear the output file
> "$OUTPUT_FILE"

# Process each accession number
while read -r accession; do
    # Skip empty lines
    if [ -z "$accession" ]; then
        continue
    fi
    
    echo "Retrieving sequence for $accession..."
    
    # Use NCBI's E-utilities to fetch the sequence
    # efetch retrieves records in the requested format from a list of UIDs
    result=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=${accession}&rettype=fasta&retmode=text")
    
    # Check if we got a valid result
    if [[ "$result" == *">"* ]]; then
        echo "$result" >> "$OUTPUT_FILE"
        echo "Successfully retrieved $accession"
    else
        echo "Failed to retrieve $accession" >&2
    fi
    
    # Be nice to NCBI servers with a short delay
    sleep 0.5
    
done < "$ACCESSION_FILE"

echo "Done! Retrieved sequences are saved in $OUTPUT_FILE"
#!/bin/bash

# Input and output file names
INPUT_FILE=$1
OUTPUT_FILE=$2
FASTA_FILE=$3

# Create CSV header
echo "accession,locustag" > $OUTPUT_FILE

# Create or clear the FASTA file
> $FASTA_FILE

while read -r locustag <&3;
do
    echo "Processing $locustag..."
    
    # Get the FASTA data for this locustag
    fasta_data=$(esearch -db protein -query "$locustag" | efetch -format fasta)
    
    # Check if we got any results
    if [ -z "$fasta_data" ]; then
        echo "No results found for $locustag"
        continue
    fi
    
    # Append the FASTA data to the combined file
    echo "$fasta_data" >> $FASTA_FILE
    
    # Extract all sequence headers (they begin with '>')
    echo "$fasta_data" | grep "^>" | while read -r header; do
        # Extract the accession from the header (text between ">" and the first space)
        accession=$(echo "$header" | cut -d ' ' -f 1 | sed 's/>//')
        
        # Write this accession with its original locustag to the CSV
        echo "$accession,$locustag" >> $OUTPUT_FILE
    done
    
done 3< $INPUT_FILE

echo "Conversion complete. Results saved to $OUTPUT_FILE"
echo "All FASTA sequences saved to $FASTA_FILE"
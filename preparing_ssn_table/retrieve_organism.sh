#!/bin/bash

# Input and output file names
INPUT_FILE=$1
OUTPUT_FILE=$2

# Create header for output file
echo -e "Accession\tOrganism\tTaxID\tTaxonomic_Lineage" > "$OUTPUT_FILE"

# Function to process a single accession
process_accession() {
    # Remove trailing $ and whitespace
    local accession=$(echo "$1" | sed -e 's/\$//g' | xargs)
    
    echo "Processing: $accession" >&2
    
    # Use NCBI's official data linking API
    # First, get the protein record
    efetch_result=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=protein&id=${accession}&rettype=gp&retmode=text")
    
    # Extract the taxonomy ID directly from the GenPept record
    taxid=$(echo "$efetch_result" | grep -m 1 "/db_xref=\"taxon:" | cut -d':' -f2 | cut -d'"' -f1)
    
    if [ -z "$taxid" ]; then
        echo -e "$accession\tNot found\tNot found\tNot found" >> "$OUTPUT_FILE"
        return
    fi
    
    # Get the organism name
    organism=$(echo "$efetch_result" | grep -m 1 "ORGANISM" | sed 's/ORGANISM  //')
    
    # Now get the full taxonomic lineage using the NCBI taxonomy database
    taxonomy_result=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=taxonomy&id=${taxid}&retmode=xml")
    
    # Extract the full lineage text
    lineage=$(echo "$taxonomy_result" | grep -o '<Lineage>.*</Lineage>' | sed 's/<Lineage>\(.*\)<\/Lineage>/\1/')
    
    # Write the results
    echo -e "$accession\t$organism\t$taxid\t$lineage" >> "$OUTPUT_FILE"
}

# Process each accession
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and remove trailing $
    cleaned_line=$(echo "$line" | sed -e 's/\$//g' | xargs)
    [ -z "$cleaned_line" ] && continue
    
    process_accession "$cleaned_line"
    
    # Avoid overloading NCBI servers
    sleep 1
    
done < "$INPUT_FILE"

echo "Results saved to $OUTPUT_FILE" >&2
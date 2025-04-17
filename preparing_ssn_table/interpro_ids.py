import pandas as pd
import csv

# Load the CSV file
df = pd.read_csv('fdhs/ssn/domain_annotations.csv')

# Function to join valid InterPro IDs (excluding nan and "Unintegrated")
def join_valid_ids(series):
    # Filter out nan and "Unintegrated" values
    valid_ids = [x for x in series if x != "nan"]

    # Join with "-" if there are valid IDs, otherwise return empty string
    if valid_ids:
        return "-".join(valid_ids)
    else:
        return ""

# Group by Sequence Name and aggregate InterPro IDs
df.columns
result = df.groupby('Accession').agg({
    'InterPro ID': list,
    'InterPro Name': join_valid_ids,
    'Name': list
}).reset_index()

result.head()
# Save to a new CSV file
result.to_csv('fdhs/ssn/domain_composition.csv', index=False, quoting=csv.QUOTE_ALL)
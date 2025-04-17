import pandas as pd

# Read each file with explicit delimiter
file1 = pd.read_csv('fdhs/ssn/80_fdhs_ssn.csv', sep=',')  # Adjust delimiter as needed
file2 = pd.read_csv('fdhs/ssn/fdhs_organisms.tsv', sep='\t')
file3 = pd.read_csv('fdhs/ssn/domain_composition.csv', sep=",")
# file4 = pd.read_csv('samhals/accession_locustag.tsv', sep="\t")

file1.columns
file2.columns
file3.columns
# file4.columns

file1.head()
file2.head()
file3.head()
# file4.head()

# Map locustags to accession-keyed table
# locustag_accession = pd.merge(file2, file4, on="Accession")
# locustag_accession.columns

# Merge the files sequentially on the common column
merged_df = pd.merge(file1, file3, on='Accession', how="left")
merged_df.columns
merged_df_2=pd.concat([merged_df, file2], ignore_index=True).drop_duplicates(subset=['name'])
merged_df_2.info

# Save the result
merged_df_2.to_csv('fdhs/ssn/full_ssn_table.csv', index=False)
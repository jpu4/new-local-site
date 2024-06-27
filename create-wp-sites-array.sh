#!/bin/bash

# Array of folder names
folders=("domain1.local" "domain2.local")

# Loop through each folder in the array
for folder in "${folders[@]}"; do
  ./create-wp-site.sh $folder
done

echo "All sites have been created."

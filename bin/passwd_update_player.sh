#!/bin/bash

# Prompt for the original and replacement words
read -p "Enter the word to replace (original password): " original
read -p "Enter the replacement word (new password): " replacement

target_dir="$HOME/etc/player_cmds"

# Check if directory exists
if [ ! -d "$target_dir" ]; then
  echo "Directory $target_dir does not exist."
  exit 1
fi

echo "Replacing '$original' with '$replacement' in all files under $target_dir..."

# Loop through regular files only
find "$target_dir" -type f | while read -r file; do
  sed -i "s/${original}/${replacement}/g" "$file"
  echo "Updated: $file"
done

echo "Replacement complete."


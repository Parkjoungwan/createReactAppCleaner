#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <start_directory>"
  exit 1
fi

start_directory="$1"

if [ ! -d "$start_directory" ]; then
  echo -e "\033[1;31mError: The specified start directory '$start_directory' does not exist.\033[0m"
  exit 1
fi

# Function to prompt for confirmation
confirm() {
  while true; do
    read -p "Do you want to replace unnecessary files and folders in '$start_directory'? (yes/no): " choice
    case $choice in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Prepare replacement files
replacement_path=$(dirname "$0")
pure_public_index_html="$replacement_path/pure_public_index.html"
pure_src_index_tsx="$replacement_path/pure_src_index.tsx"
pure_app_tsx="$replacement_path/pure_app.tsx"

# Function to update index.tsx files
update_index_tsx() {
  index_file="$1"
  for file in favicon.ico logo192.png logo512.png manifest.json robots.txt; do
    if grep -q "$file" "$index_file" 2> /dev/null; then
      sed -i "/$file/d" "$index_file"
    else
      echo -e "\033[1;31mWarning: $file not found in $index_file. Skipping...\033[0m"
    fi
  done
}


# Function to check if files are the same
are_files_same() {
  file1="$1"
  file2="$2"
  if cmp -s "$file1" "$file2"; then
    echo 0
  else
    echo 1
  fi
}

# Ask for confirmation
confirm && {
  # Update public/index.tsx
  update_index_tsx "$start_directory/public/index.html"
  if [ $(are_files_same "$pure_public_index_html" "$start_directory/public/index.html") -eq 1 ]; then
    cp "$pure_public_index_html" "$start_directory/public/index.html"
  else
    echo -e "\033[1;31mWarning: Skipping replacement for public/index.tsx, same file exists.\033[0m"
  fi

  # Delete unnecessary files
  for file in favicon.ico logo192.png logo512.png manifest.json robots.txt; do
    if [ -f "$start_directory/public/$file" ]; then
      rm "$start_directory/public/$file"
    else
      echo -e "\033[1;31mWarning: $start_directory/public/$file not found. Skipping...\033[0m"
    fi
  done

  # Update src/index.tsx
  update_index_tsx "$start_directory/src/index.html"
  if [ $(are_files_same "$pure_src_index_tsx" "$start_directory/src/index.tsx") -eq 1 ]; then
    cp "$pure_src_index_tsx" "$start_directory/src/index.tsx"
  else
    echo -e "\033[1;31mWarning: Skipping replacement for src/index.tsx, same file exists.\033[0m"
  fi

  # Delete unnecessary files
  for file in index.css logo.svg App.css App.test.js logo.svg serviceWorker.js; do
    if [ -f "$start_directory/src/$file" ]; then
      rm "$start_directory/src/$file"
    else
      echo -e "\033[1;31mWarning: $start_directory/src/$file not found. Skipping...\033[0m"
    fi
  done

  # Replace src/App.tsx
  if [ $(are_files_same "$pure_app_tsx" "$start_directory/src/App.tsx") -eq 1 ]; then
    cp "$pure_app_tsx" "$start_directory/src/App.tsx"
  else
    echo -e "\033[1;31mWarning: Skipping replacement for src/App.tsx, same file exists.\033[0m"
  fi

  # Delete unnecessary folders
  if [ -d "$start_directory/src/components" ]; then
    rm -r "$start_directory/src/components"
  else
    echo -e "\033[1;31mWarning: $start_directory/src/components not found. Skipping...\033[0m"
  fi
  if [ -f "$start_directory/src/setupTests.js" ]; then
    rm -r "$start_directory/src/setupTests.js"
  else
    echo -e "\033[1;31mWarning: $start_directory/src/setupTests.js not found. Skipping...\033[0m"
  fi
  
  echo -e "\033[1;32mUnnecessary files and folders replaced in '$start_directory'.\033[0m"
} || {
  echo -e "\033[1;31mReplacement process canceled.\033[0m"
}


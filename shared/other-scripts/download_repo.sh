#!/bin/bash

# Check if the required parameters are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <repo-url> <destination-folder>"
    exit 1
fi

# Assign parameters to variables
REPO_URL="$1"
DESTINATION_FOLDER="$2"

# Extract repository name and branch from the URL
REPO_NAME=$(basename -s .git "$REPO_URL")
BRANCH="main" # Default branch, adjust if needed

# Construct the ZIP download URL
ZIP_URL="${REPO_URL}/archive/refs/heads/${BRANCH}.zip"

# Temporary ZIP file name
ZIP_FILE="/tmp/${REPO_NAME}.zip"

# Function to download and extract the repository
download_and_extract() {
    echo "Downloading repository from $ZIP_URL..."
    curl -L -o "$ZIP_FILE" "$ZIP_URL"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download the repository."
        exit 1
    fi

    echo "Extracting files to $DESTINATION_FOLDER..."
    mkdir -p "$DESTINATION_FOLDER"
    unzip -q "$ZIP_FILE" -d /tmp
    mv "/tmp/${REPO_NAME}-${BRANCH}"/* "$DESTINATION_FOLDER"
    
    # Cleanup
    rm -rf "$ZIP_FILE" "/tmp/${REPO_NAME}-${BRANCH}"

    echo "Repository downloaded and extracted to: $DESTINATION_FOLDER"
}

# Run the function
download_and_extract
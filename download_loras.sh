#!/bin/bash

# Directory URL on HuggingFace
BASE_URL="https://huggingface.co/ProjectGasm/mod3l-hub/tree/main/L0RAS"

# Target directory on your workspace
TARGET_DIR="/workspace/repositories/Fooocus/models/loras/"

# Create the target directory if it doesn't exist
mkdir -p $TARGET_DIR

# Fetch the list of files in the directory and download them
wget -q -O - $BASE_URL | grep -oP '(?<=href=")[^"]*(?=.safetensors")' | while read -r FILE_PATH; do
    FILE_NAME=$(basename $FILE_PATH)
    FILE_URL="https://huggingface.co${FILE_PATH}"
    wget -O "${TARGET_DIR}/${FILE_NAME}" "${FILE_URL}?download=true"
done

#!/bin/bash

# URL repo
REPO_URL="https://github.com/tms-dos21-onl/_sandbox.git"

# Make sure you pass the argument with the name of the repository
#if [ -z "$1" ]; then
#  echo "Usage: $0 <repository-url>"
#  exit 1
#fi

# Repository cloning
#echo "Cloning the repository..."
#git clone "$1"
#REPO_NAME=$(basename "$1" .git)
#cd "$REPO_NAME" || { echo "Failed to enter directory $REPO_NAME"; exit 1; }
echo "Cloning the repository..."
git clone "$REPO_URL"
REPO_NAME=$(basename "$REPO_URL" .git)
cd "$REPO_NAME" || { echo "Failed to enter directory $REPO_NAME"; exit 1; }

# Upstream addition
echo "Adding upstream..."
git remote add upstream "$1"

# Upstream Change Receipt
echo "Fetching upstream..."
git fetch upstream

# Switch to main branch
echo "Checking out main branch..."
git checkout main

# Merge changes from upstream/main
echo "Merging upstream/main..."
git merge upstream/main

# Upload changes to origin/main
echo "Pushing changes to origin/main..."
git push origin main

echo "Repository updated successfully."

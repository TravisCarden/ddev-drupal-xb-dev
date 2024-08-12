#!/usr/bin/env sh

cd "$(dirname "$0")/../var" && clear || exit 1
clear; set -ev

PROJECT_DIR="test"
PROJECT_NAME=drupal-xb-dev-test

# Clean up from previous runs.
PROJECT_EXISTS=$(ddev list | grep -q $PROJECT_NAME) || true
if [ -d $PROJECT_DIR ] || [ -n "$PROJECT_EXISTS" ]; then
  yes | ddev clean $PROJECT_NAME || true
  ddev remove --unlist $PROJECT_NAME || true
  rm -rf $PROJECT_DIR || true
fi

mkdir $PROJECT_DIR || true
cd $PROJECT_DIR || exit 1

# Create a new project.
ddev config \
  --project-name=$PROJECT_NAME \
  --project-type=drupal \
  --php-version=8.3 \
  --docroot=web

# Get the add-on.
ddev get ../../

# Run Cypress.
ddev xb-cypress-open

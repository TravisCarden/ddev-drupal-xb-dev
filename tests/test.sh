#!/usr/bin/env sh

# This file is for self-testing this add-on during local development.
#
# First, install XQuartz (and ONLY XQuartz) according to the instructions at
# https://github.com/TravisCarden/ddev-drupal-xb-dev#prerequisites-xquartz
# (Stop after configuring XQuartz--do not continue with the steps in the README.
#
# Then run the following commands on your host machine to clone the
# repository fresh and run the script:
#
#   cd ~/Projects/temp # This can be anywhere you want.
#   git clone git@github.com:TravisCarden/ddev-drupal-xb-dev.git
#   cd ddev-drupal-xb-dev
#   ./tests/test.sh

PROJECT_NAME="ddev-drupal-xb-dev"
PROJECT_DIR="test-site"
DRUPAL_VERSION="10.x@dev"

cd "$(dirname "$0")/../var" && clear || exit 1
clear; set -ev

# Clean up from previous runs.
PROJECT_EXISTS=$(ddev list | grep -q "$PROJECT_NAME.ddev.site") || true
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

# Configure the new DDEV project.
ddev config --project-type=drupal --php-version=8.3 --docroot=web

# Create the Drupal project.
ddev composer create drupal/recommended-project:$DRUPAL_VERSION --no-install

# Get the add-on.
ddev add-on get ../../

# Perform one-time setup operations.
ddev xb-setup

# Test an update.
ddev add-on get ../../

# Try to perform one-time setup operations when they've already been done.
ddev xb-setup

# Make sure all the commands get installed.
DDEV_HELP_OUTPUT=$(ddev help)
find "commands" -name 'xb-*' -exec basename {} \; | while read -r COMMAND_NAME; do
  if ! echo "$DDEV_HELP_OUTPUT" | grep -q "$COMMAND_NAME"; then
    echo "Error: $COMMAND_NAME is not installed."
    exit 1
  fi
done
echo "All commands are installed."

# Install dev extras.
ddev xb-dev-extras

# Configure environment for Workspaces development.
ddev xb-workspaces-dev

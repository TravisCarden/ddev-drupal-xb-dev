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

# Configure the new DDEV project.
ddev config --project-type=drupal --php-version=8.3 --docroot=web

# Create the Drupal project.
ddev composer create drupal/recommended-project:^11.x-dev --no-install

# Get the add-on.
ddev get ../../

# Perform one-time setup operations.
ddev xb-setup

# Test an update.
ddev get ../../

# Try to perform one-time setup operations when they've already been done.
ddev xb-setup

# Make sure all the commands get installed.
DDEV_HELP_OUTPUT=$(ddev help)
for COMMAND_NAME in $(find "$(dirname "$0")/../commands" -name 'xb-*' -exec basename {} \;); do
  if ! echo "$DDEV_HELP_OUTPUT" | grep -q "$COMMAND_NAME"; then
    echo "Error: $COMMAND_NAME is not installed."
    exit 1
  fi
done
echo "All commands are installed."

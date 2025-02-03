#!/usr/bin/env bash

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

set -e # Exit immediately if a command exits with a non-zero status.
set -o pipefail # Return the exit status of the last command in the pipeline that failed.
set -x  # Enable debugging.

cd "$(dirname "$0")/../var" && clear || exit 1

var_dir=$(pwd)
project_name="drupal-xb-dev-test-site"
project_dir="test-site"

addon="$var_dir/../"
#addon="TravisCarden/ddev-drupal-xb-dev"

drupal_version="10.x@dev"
#drupal_version="^11.x-dev"

num_runs=1  # The number of times to run the test
declare -a failure_logs  # Array to store failure details

# Color codes
green="\033[0;32m"
red="\033[0;31m"
reset_color="\033[0m"

run_test() {
  cd "$var_dir" || exit 1

  ## Clean up from previous runs.
  echo "Cleaning up from previous runs..."
  if ddev list | grep -q "$project_name"; then
    ddev remove \
      --omit-snapshot \
      --unlist \
      "$project_name" || { failure_logs+=("ddev remove"); return 1; }
  fi
  rm -rf "$project_dir" || true

  # Create a new project.
  mkdir "$project_dir" || { failure_logs+=("mkdir $project_dir"); return 1; }
  cd "$project_dir" || { failure_logs+=("cd $project_dir"); return 1; }
  echo "Running ddev config --project-name=$project_name --project-type=drupal --php-version=8.3 --docroot=web..."
  ddev config \
    --project-name="$project_name" \
    --project-type=drupal \
    --php-version=8.3 \
    --docroot=web || { failure_logs+=("ddev config"); return 1; }

  # Create the Drupal project.
  echo "Running ddev composer create drupal/recommended-project:$drupal_version --no-install..."
  ddev composer create drupal/recommended-project:"$drupal_version" --no-install || { failure_logs+=("ddev composer create drupal/recommended-project:$drupal_version --no-install"); return 1; }

  # Get the add-on.
  echo "Running ddev add-on get $addon..."
  ddev add-on get "$addon" || { failure_logs+=("ddev add-on get $addon"); return 1; }

  # Make sure all the commands got installed and registered.
  ddev_help_output=$(ddev help) || { failure_logs+=("ddev help"); return 1; }
  errors=""
  echo
  echo "Verifying that all commands are fully installed and registered..."
  find ".ddev/commands" -name 'xb-*' -exec basename {} \; | while read -r command_name; do
    # Skip xb-cypress on CI since it only gets installed on Mac.
    if [ "$command_name" = "xb-cypress" ] && [ -n "$GITHUB_ACTIONS" ]; then
      continue
    fi
    if echo "$ddev_help_output" | grep -q "$command_name"; then
      echo -e "- ${green}PASS:${reset_color} '$command_name' registered"
    else
      echo -e "- ${red}FAIL:${reset_color} '$command_name' not registered"
      errors="true"
    fi
  done || { failure_logs+=("find .ddev/commands"); return 1; }
  if [ -n "$errors" ]; then
    return 1
  fi
  echo

  # Perform one-time setup operations.
  echo "Running ddev xb-setup..."
  ddev xb-setup || { failure_logs+=("ddev xb-setup"); return 1; }

  ddev xb-dev-extras || { failure_logs+=("ddev xb-dev-extras"); return 1; }

  ddev xb-workspaces-dev || { failure_logs+=("ddev xb-workspaces-dev"); return 1; }

  ddev drush uli || { failure_logs+=("ddev drush uli"); return 1; }
}

# Initialize counters.
success_count=0
failure_count=0

# Run tests.
for ((i = 1; i <= num_runs; i++)); do
  if run_test; then
    # Success
    echo "Success"
    ((success_count++))
  else
    # Failure
    echo "Failed"
    ((failure_count++))
  fi
done

# Print summary.
echo
echo "Summary:"
echo "Add-on: $addon"
echo "Drupal version: $drupal_version"
echo "Successes: $success_count"
echo "Failures: $failure_count"

# Print failure logs if there were failures.
if ((failure_count > 0)); then
  echo "Failed Commands:"
  for failure in "${failure_logs[@]}"; do
    echo " - $failure"
  done
  exit 1
fi

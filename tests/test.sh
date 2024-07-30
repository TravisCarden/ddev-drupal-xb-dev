#!/usr/bin/env sh

cd "$(dirname "$0")/../var" && clear || exit 1

# Clean up
SITE_NAME=drupal-xb-dev-test
yes | ddev clean $SITE_NAME || true
rm -rf $SITE_NAME || true
mkdir $SITE_NAME
cd $SITE_NAME || exit 1

# Create a new project.
ddev config --project-type=drupal --php-version=8.3 --docroot=web
ddev get ../../
ddev status

# Exercise the custom command.
ddev xb-cypress-run --spec "e2e/canary.cy.js"

# DDEV Drupal Experience Builder Devel

This configures a DDEV environment for Drupal [Experience Builder](https://www.drupal.org/project/experience_builder) (XB) module development. Specifically, it sets up the front-end dependencies and provides Cypress JavaScript testing functionality.

> ⚠️ **Note:** This a work-in-progress. It functions properly, but there's a little more automation and polish on the way.
See [DDEV support for Cypress tests [#3458369] | Drupal.org](https://www.drupal.org/project/experience_builder/issues/3458369).

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Requirements

Obviously, this requires a working [DDEV](https://ddev.com/) installation.

## Installation

```shell
# Create a new directory for your dev site:
mkdir ~/Sites/xb-dev && cd ~/Sites/xb-dev

# Configure the new environment.
ddev config --project-type=drupal --php-version=8.3 --docroot=web

# Get the add-on.
ddev get TravisCarden/ddev-drupal-xb-dev
```

## Usage

The resulting DDEV instance is just like any other one. Interact with it using [the built-in commands](https://ddev.readthedocs.io/en/stable/users/usage/commands/), e.g., `ddev launch` to browse the site.

The installation process clones [the Experience Builder module](https://www.drupal.org/project/experience_builder) into `web/modules/contrib/experience_builder` and places an `experience_builder` symlink to it at the project root for convenient access. Develop and contribute from either location like you would any other Git repo for a normal Drupal project.

To browse the site, run:

```shell
ddev launch
```

To log into the Drupal site, run:

```shell
ddev drush uli
```

To clean install the module's UI app, i.e., rebuild its front-end assets.

```shell
ddev xb-npm-ci
```

To run Cypress tests, use the provided command:

```shell
ddev xb-cypress-run                       # Run all tests.
ddev xb-cypress-run "e2e/*.cy.js"         # Run all end-to-end tests.
ddev xb-cypress-run "e2e/example.cy.js"   # Run a specific test.
```

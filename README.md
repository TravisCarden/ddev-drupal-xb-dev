# DDEV Drupal Experience Builder Devel

This configures a DDEV environment for Drupal Experience Builder (XB) module development. Specifically, it sets up the front-end dependencies and provides Cypress JavaScript testing functionality.

> ⚠️ **Note:** This a work-in-progress. It functions properly, but there's a little more automation and polish on the way.
See [DDEV support for Cypress tests [#3458369] | Drupal.org](https://www.drupal.org/project/experience_builder/issues/3458369).

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Requirements

Obviously, this requires a working [DDEV](https://ddev.com/) installation.

## Installation

The installation process is not yet in its final form--it takes more steps than it will in the end. Specifically, it will not ultimately be necessary to clone the add-on repo or manually run the `npm` commands. In the meantime...

```shell
# Clone the add-on into a convenient directory.
git clone git@github.com:TravisCarden/ddev-drupal-xb-dev.git ~/Projects/ddev-drupal-xb-dev

# Create a new directory for your dev site:
mkdir ~/Sites/xb-dev && cd ~/Sites/xb-dev

# Configure the new environment.
ddev config --project-type=drupal --php-version=8.3 --docroot=web

# Get the add-on from the local clone.
ddev get ~/Projects/ddev-drupal-xb-dev

# Initialize the environment.
ddev start

# Install and build the front-end assets.
ddev npm --prefix /var/www/html/web/modules/contrib/experience_builder/ui install
ddev npm --prefix /var/www/html/web/modules/contrib/experience_builder/ui run build
```

## Usage

The resulting DDEV instance is just like any other one. Interact with it using [the built-in commands](https://ddev.readthedocs.io/en/stable/users/usage/commands/), e.g., `ddev launch` to browse the site.

The installation process clones [the Experience Builder module](https://www.drupal.org/project/experience_builder) into `web/modules/contrib/experience_builder`. Develop and contribute from there like any other Git repo for a normal Drupal project.

To run Cypress tests, use the provided command:

```shell
ddev cypress                       # Run all tests.
ddev cypress "e2e/*.cy.js"         # Run all end-to-end tests.
ddev cypress "e2e/example.cy.js"   # Run a specific test.
```

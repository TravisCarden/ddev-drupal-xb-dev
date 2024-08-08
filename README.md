# DDEV Drupal Experience Builder Devel

This configures a DDEV environment for Drupal [Experience Builder](https://www.drupal.org/project/experience_builder) (XB) module development. Specifically, it sets up the front-end dependencies and provides Cypress JavaScript testing functionality.

> ⚠️ **Notice:**
> - This a work-in-progress. See [DDEV support for Cypress tests [#3458369] | Drupal.org](https://www.drupal.org/project/experience_builder/issues/3458369).
> - Cypress testing is currently only supported on macOS.

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Requirements

Obviously, this requires a working [DDEV](https://ddev.com/) installation.

## Installation

```shell
# On macOS, install the XQuartz X Window System for Cypress testing.
# See https://www.xquartz.org/ or use Homebrew, like this:
brew install xquartz

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

### Browsing and development

To browse the site, run:

```shell
ddev launch
```

To log into Drupal, run:

```shell
ddev drush uli
```

To clean-install the module's UI app, i.e., rebuild its front-end assets, run:

```shell
ddev xb-npm-ci
```

### Cypress

Cypress testing is currently only supported on macOS.

To run the tests interactively, use `ddev xb-cypress-open`:

```shell
ddev xb-cypress-open
```

To run them headlessly, use `ddev xb-cypress-run`:

```shell
ddev xb-cypress-run                             # Run all tests.
ddev xb-cypress-run --spec "e2e/*.cy.js"        # Run all end-to-end tests.
ddev xb-cypress-run --spec "e2e/canary.cy.js"   # Run a specific test.
```

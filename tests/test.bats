# Exit on error, treat unset variables as errors, and ensure pipelines fail on the first command failure.
set -eu -o pipefail

# Setup environment for the test.
setup() {
  DIR="$(cd "$(dirname "$0")/.." && pwd)"
  export DIR
  TESTDIR="${DIR}/var/test"
  export TESTDIR
  export PROJNAME="drupal-xb-test"
  export DDEV_NONINTERACTIVE="true"

  # Ensure a clean environment.
  if [ -d "${TESTDIR}" ]; then
    ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
    rm -rf "${TESTDIR}"
  fi

  mkdir -p "${TESTDIR}/web/sites/default" || true
  cd "${TESTDIR}" || exit 1

  # Configure the DDEV project.
  ddev config \
    --project-name="${PROJNAME}" \
    --project-type=drupal \
    --php-version=8.3 \
    --docroot=web >/dev/null

  # Start the DDEV project.
  if ! ddev start -y >/dev/null; then
    echo "DDEV failed to start."
    ddev logs
    exit 1
  fi
}

# Verify that all required commands are installed.
check_commands_installed() {
  # Get the available commands.
  ddev_help_output="$(ddev help)"

  # Find command files in the add-on.
  tmp_file="$(mktemp)"
  find "${DIR}/commands" -name 'xb-*' -exec basename {} \; > "${tmp_file}" || {
    echo "Error: No 'commands' directory found at ${DIR}/commands."
    exit 1
  }

  # Check that all the command files got copied to the project upon installation.
  errors=""
  while read -r command_name; do
    # Skip xb-cypress since it's expected not to be installed on CI.
    if [ "${command_name}" = "xb-cypress" ]; then
      continue
    fi

    if ! echo "${ddev_help_output}" | grep -q "${command_name}"; then
      errors="${errors}Error: ${command_name} is not installed.\n"
    fi
  done < "${tmp_file}"
  rm -f "${tmp_file}"

  # Display errors and fail, if any.
  if [ -n "${errors}" ]; then
    printf "%b" "${errors}"
    return 1
  fi

  echo "All commands were installed successfully."
}

# Check that the xb-setup command works as expected.
check_xb_setup_command() {
  ddev xb-setup

  # Verify that settings.php contains the expected customizations.
  if ! grep -q "extension_discovery_scan_tests" "web/sites/default/settings.ddev.php"; then
    echo "Failed to enable extension_discovery_scan_tests in settings.ddev.php."
    return 1
  fi

  echo "Successfully enabled extension_discovery_scan_tests in settings.ddev.php."
}

# Check that the xb-dev-extras command works as expected.
check_xb_dev_extras_command() {
  ddev xb-dev-extras
}

# Perform a basic HTTP request to ensure the site is reachable.
check_site_reachable() {
  ddev exec "curl -s https://localhost:443/"
}

# Perform health checks on the installed add-on.
health_checks() {
  check_commands_installed
  check_xb_setup_command
  check_xb_dev_extras_command
  check_xb_dev_extras_command
  check_site_reachable
}

# Clean up resources after the test.
teardown() {
  if [ -d "${TESTDIR}" ]; then
    cd "${TESTDIR}" || exit 1
    ddev delete -Oy "${PROJNAME}" || true
    rm -rf "${TESTDIR}" || true
  fi
}

# Test installation of the add-on from a local directory.
@test "install from directory" {
  cd "${TESTDIR}" || exit 1
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get "${DIR}"
  ddev restart

  health_checks
}

# Test installation of the add-on from a release.
# bats test_tags=release
@test "install from release" {
  cd "${TESTDIR}" || exit 1
  echo "# ddev add-on get TravisCarden/ddev-drupal-xb-dev with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get TravisCarden/ddev-drupal-xb-dev
  ddev restart >/dev/null

  health_checks
}

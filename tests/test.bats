setup() {
  set -eu -o pipefail
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )/.."
  export DIR
  export TESTDIR=~/tmp/drupal-xb-dev
  mkdir -p $TESTDIR
  export PROJNAME=drupal-xb-dev
  export DDEV_NONINTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME}
  ddev start -y >/dev/null
}

check_commands_installed() {
  # Get the available commands.
  ddev_help_output=$(ddev help)
  # Find command files in the add-on.
  cd "${TESTDIR}"
  tmp_file=$(mktemp)
  find "$GITHUB_WORKSPACE/commands" -name 'xb-*' -exec basename {} \; > "$tmp_file"
  # Check that all the command files got copied to the project upon installation.
  errors=""
  while read -r command_name; do
    # Skip xb-cypress since it's expected not to be installed on CI.
    if [ "$command_name" = "xb-cypress" ]; then
      continue
    fi
    if ! echo "$ddev_help_output" | grep -q "$command_name"; then
      errors="${errors}Error: ${command_name} is not installed.\n"
    fi
  done < "$tmp_file"
  rm -f "$tmp_file"
  # Display errors and fail, if any.
  if [ -n "$errors" ]; then
    printf "%b" "$errors"
    return 1
  fi
  echo "All commands were installed."
}

health_checks() {
  check_commands_installed
  ddev exec "curl -s https://localhost:443/"
}

teardown() {
  set -eu -o pipefail
  cd "${TESTDIR}" || ( printf "unable to cd to %s\n" "${TESTDIR}" && exit 1 )
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
}

@test "install from directory" {
  set -eu -o pipefail
  cd "${TESTDIR}"
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get "${DIR}"
  ddev restart
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  cd "${TESTDIR}" || ( printf "unable to cd to %s\n" "${TESTDIR}" && exit 1 )
  echo "# ddev add-on get TravisCarden/ddev-drupal-xb-dev with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get TravisCarden/ddev-drupal-xb-dev
  ddev restart >/dev/null
  health_checks
}

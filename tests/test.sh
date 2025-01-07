#!/usr/bin/env sh

# This runs bats tests basically as they are run on CI. It uses the system temp
# directory and leaves no artifacts. To create a persistent installation in
# :/var/test that you can manually test and interact with, use manual.sh.

cd "$(dirname "$0")" && clear || exit 1
clear; set -ev

./bats/bin/bats test.bats

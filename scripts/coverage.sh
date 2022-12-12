#!/usr/bin/env bash

# Exit if anything fails
set -euo pipefail

# Change directory to project root
SCRIPT_PATH="$( cd "$( dirname "$0" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_PATH/.." || exit

# Utilities
GREEN='\033[00;32m'

function log () {
    echo -e "$1"
    echo "#########################################################"
    echo "#### $2 "
    echo "#########################################################"
    echo -e "\033[0m"
}

# Check for lcov dependency
if ! [ -x "$(command -v genhtml)" ]; then
  echo 'Error: lcov is not installed. (sudo apt install lcov)' >&2
  exit 1
fi

# Check for http-server dependency
if ! [ -x "$(command -v http-server)" ]; then
  echo 'Error: http-server is not installed. (npm install -g http-server)' >&2
  exit 1
fi

log $GREEN "Running Coverage script"

mkdir -p reports

forge coverage --report lcov

genhtml --branch-coverage -o reports/coverage lcov.info

http-server reports/coverage -o -c-1 -p 0

log $GREEN "Done"
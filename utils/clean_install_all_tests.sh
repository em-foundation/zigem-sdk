#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

${SCRIPT_DIR}/clean.sh -d
${SCRIPT_DIR}/install.sh
${SCRIPT_DIR}/basic_tests.sh
${SCRIPT_DIR}/combo_tests.sh

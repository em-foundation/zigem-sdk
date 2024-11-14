#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd ${SCRIPT_DIR}/../ > /dev/null

printf "\nInstalling zigem\n"
zig build

printf "\nVerifying zigem installation\n"
zig build verify

popd > /dev/null

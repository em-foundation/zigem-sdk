#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd ${SCRIPT_DIR}/../ > /dev/null

echo "Installing zigem"
zig build
echo "Verifying zigem installation"
zig build verify

popd > /dev/null

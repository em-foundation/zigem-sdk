#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd ${SCRIPT_DIR}/../ > /dev/null

printf "\nInstalling zigem\n"
zig build

printf "\nVerifying zigem installation\n"
zig build verify

latestVsix=$(ls zig-out/tools/vscode-zigem*.vsix | tail -n 1)
if [ "$latestVsix" != "" ]; then
  printf "\nInstall zigem vscode extension\n"
  code --install-extension $latestVsix
else
  printf "\nNo vscode extension found in zig-out/tools\n"
fi

popd > /dev/null

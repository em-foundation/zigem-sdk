#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

Color_Off=
Black=
Red=
Green=
Yellow=
Blue=
Purple=
Cyan=
White=
if [ -t 1 ]; then
  if [[ -n "$TERM" ]] && [[ "$TERM" != "dumb" ]]; then
    Color_Off='\033[0m'
    Black='\033[0;30m'
    Red='\033[0;31m'
    Green='\033[0;32m'
    Yellow='\033[0;33m'
    Blue='\033[0;34m'
    Purple='\033[0;35m'
    Cyan='\033[0;36m'
    White='\033[0;37m'
  fi
fi

pushd ${SCRIPT_DIR}/../ > /dev/null

printf "\n${Green}>>> Install zigem <<<${Color_Off}\n"
if [ "$(which zig)" == "" ]; then
  printf "${Red}*** Required zig program not found in path ***${Color_Off}\n"
else
  zig build --release=safe --summary all
fi

printf "\n${Green}>>> Verify zigem installation <<<${Color_Off}\n"
if [ "$(which make)" == "" ]; then
  printf "${Red}*** Required make program not found in path ***${Color_Off}\n"
else
  zig build verify
fi

zigemExtensionId=the-em-foundation.vscode-zigem
printf "\n${Green}>>> Install zigem vscode extension <<<${Color_Off}\n"
code --install-extension $zigemExtensionId --force
printf "${Green}>>> Installation complete <<<${Color_Off}\n"

popd > /dev/null

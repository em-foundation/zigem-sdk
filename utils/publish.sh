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

printf "\n${Green}>>> Publishing zig.em files <<<${Color_Off}\n"
autocrlf=$(git config --global -l | grep autocrlf)
if [[ ( "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ) && "$autocrlf" != "core.autocrlf=input" ]]; then
  printf "${Red}*** Do 'git config --global core.autocrlf input' before zigem publish${Color_Off}\n"
else
  printf "$(find ${SCRIPT_DIR}/../workspace/ -name '*.em.zig' -exec ${SCRIPT_DIR}/../zig-out/bin/zigem publish -f {} --force \; | wc -l) files published\n"
  printf "${Green}>>> Publishing zig.em files complete <<<${Color_Off}\n"
fi

popd > /dev/null

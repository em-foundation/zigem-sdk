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

buildOnly=
promptBetween=

Help()
{
   # Display Help
   echo "Run basic end-to-end tests"
   echo
   echo "options:"
   echo "b     Build only -- do not load/run"
   echo "p     Prompt between tests"
   echo "h     Print this Help."
   echo
}

while getopts ":hbp" option; do
   case $option in
      h)
         Help
         exit
         ;;
      b)
         buildOnly="-b"
         ;;
      p)
         promptBetween="-p"
         ;;
     \?)
         echo "Error: Invalid option"
         exit
         ;;
   esac
done

printf "\n${Green}>>> Full Test Suite <<<${Color_Off}\n"

${SCRIPT_DIR}/clean.sh -d
if [ "${promptBetween}" != "" ]; then
   read -p ">>> Once ready, press enter to continue"
fi

${SCRIPT_DIR}/install.sh
if [ "${promptBetween}" != "" ]; then
   read -p ">>> Once ready, press enter to continue"
fi

${SCRIPT_DIR}/basic_tests.sh $buildOnly $promptBetween
${SCRIPT_DIR}/combo_tests.sh $buildOnly $promptBetween

printf "\n${Green}>>> Full Test Suite complete <<<${Color_Off}\n"

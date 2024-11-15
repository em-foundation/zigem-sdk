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

RunTest() {
  load="-l"
  if [ "${3}" != "" ]; then
    load=
  fi
  printf "\n${1}\n"
  ${SCRIPT_DIR}/../zig-out/bin/zigem compile -f ${1} ${load} | grep 'image size:'
  if [ "${3}" == "" ]; then
    printf "${2}"
  fi
  if [ "${4}" != "" ]; then
    read -p ">>> Once ready, press enter to continue"
  fi
}

while getopts ":hbp" option; do
   case $option in
      h)
         Help
         exit
         ;;
      b)
         buildOnly="-b"
         load=""
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

pushd ${SCRIPT_DIR}/../workspace > /dev/null

if [ "$buildOnly" == "" ]; then
  printf "${Yellow}\nBe sure that CC2340 LaunchPad is connected via XDS-100\n"
  printf "Also start SerialMonitor listening to the XDS-100 port at 115200,8n1n\n\n${Color_Off}"
  if [ "$promptBetween" != "" ]; then
    read -p ">>> Once ready, press enter to start tests"
  fi
fi
title="(build, load, and run)"
if [ "${buildOnly}" != "" ]; then
  title="(build only)"
fi

printf "\n${Green}>>> Combo Examples Tests ${title} <<<${Color_Off}\n"
RunTest "em.core/em.examples.combo/Ex01_TickerP.em.zig" "    you should see occasional blinks of the red and green LEDs\n    and button clicks should change the rate\n    and printout on the serial port\n" "$buildOnly" "$promptBetween"
printf "\n${Green}>>> Combo Examples Tests complete <<<${Color_Off}\n"

popd > /dev/null

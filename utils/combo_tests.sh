#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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
  title="(build, load, and run)"
  load="-l"
  if [ "${3}" != "" ]; then
    load=
    title="(build only)"
  fi
  printf "\n${1} ${title}\n"
  zigem compile -f ${1} ${load} | grep 'image size:'
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
  printf "\nBe sure that CC2340 LaunchPad is connected via XDS-100\n"
  printf "Also start SerialMonitor listening to the XDS-100 port at 115200,8n1n\n\n"
  if [ "$promptBetween" != "" ]; then
    read -p ">>> Once ready, press enter to start tests"
  fi
fi

RunTest "em.core/em.examples.combo/Ex01_TickerP.em.zig" "    you should see occasional blinks of the red and green LEDs\n    and button clicks should change the rate\n    and printout on the serial port\n" "$buildOnly" "$promptBetween"

popd > /dev/null

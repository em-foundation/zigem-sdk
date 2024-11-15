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
         exit;;
      b)
         buildOnly="-b";;
      p)
         promptBetween="-p";;
     \?)
         echo "Error: Invalid option"
         exit;;
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

printf "\n${Green}>>> Basic Examples Tests ${title} <<<${Color_Off}\n"
RunTest "em.core/em.examples.basic/Ex01_HelloP.em.zig" "    you should see 'hello world' on the serial\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex02_BlinkerP.em.zig" "    you should see 5 slow blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex03_BlinkerDbgP.em.zig" "    you should see 10 medium-speed blinks of the green LED and some printouts on the serial\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex04_FiberP.em.zig" "    you should see 5 fast blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex05_Button1P.em.zig" "    every button push should result in a fast blink of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex06_Button2P.em.zig" "    every button push should result in a fast blink of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex07_Button3P.em.zig" "    every button push should result in a fast blink of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex08_OneShot1P.em.zig" "    you should see 5 very fast blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex09_OneShot2P.em.zig" "    you should see 5 very fast blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex10_PollerP.em.zig" "    you should see 5 very fast blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex11_Alarm1P.em.zig" "    you should see occasional blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex12_Alarm2P.em.zig" "    you should see occasional blinks of the green LED\n" "$buildOnly" "$promptBetween"
RunTest "em.core/em.examples.basic/Ex13_TickerP.em.zig" "    you should see occasional blinks of the red and green LEDs\n" "$buildOnly" "$promptBetween"
printf "${Green}>>> Basic Examples Tests complete <<<${Color_Off}\n"

popd > /dev/null

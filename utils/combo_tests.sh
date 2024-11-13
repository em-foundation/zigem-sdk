#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd ${SCRIPT_DIR}/../workspace > /dev/null

printf "\nBe sure that CC2340 LaunchPad is connected via XDS-100\n"
printf "Also start SerialMonitor listening to the XDS-100 port at 115200,8n1n\n\n"
read -p "Once ready, press enter to start tests"

printf "\nCombo/Ex01_TickerP -- you should see occasional blinks of the red and green LEDs\n"
printf "... and button clicks should change the rate ... and printout on the serial port\n"
zigem compile -f em.core/em.examples.combo/Ex01_TickerP.em.zig -l
read -p "Once ready, press enter to exit the tests"

popd > /dev/null

#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pushd ${SCRIPT_DIR} > /dev/null

./clean.sh -d
zig build
zig build verify

printf "\nBe sure that CC2340 LaunchPad is connected via XDS-100\n"
printf "Also start SerialMonitor listening to the XDS-100 port at 115200,8n1n\n\n"
read -p "Once ready, press enter to start tests"

cd workspace

printf "\nEx01_HelloP -- you should see 'hello world' on the serial\n"
zigem compile -f em.core/em.examples.basic/Ex01_HelloP.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx02_BlinkerP -- you should see 5 slow blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex02_BlinkerP.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx03_BlinkerDbgP -- you should see 10 medium-speed blinks of the green LED and some printouts on the serial\n"
zigem compile -f em.core/em.examples.basic/Ex03_BlinkerDbgP.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx04_FiberP -- you should see 5 fast blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex04_FiberP.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx05_Button1P -- every button push should result in a fast blink of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex05_Button1P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx06_Button2P -- every button push should result in a fast blink of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex06_Button2P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx07_Button3P -- every button push should result in a fast blink of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex07_Button3P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx08_OneShot1P -- you should see 5 very fast blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex08_OneShot1P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx09_OneShot2P -- you should see 5 very fast blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex09_OneShot2P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx10_PollerP -- you should see 5 very fast blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex10_PollerP.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx11_Alarm1P -- you should see occasional blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex11_Alarm1P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx12_Alarm2P -- you should see occasional blinks of the green LED\n"
zigem compile -f em.core/em.examples.basic/Ex12_Alarm2P.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nEx13_TickerP -- you should see occasional blinks of the red and green LEDs\n"
zigem compile -f em.core/em.examples.basic/Ex13_TickerP.em.zig -l
read -p "Once ready, press enter to go to the next test"

printf "\nCombo/Ex01_TickerP -- you should see occasional blinks of the red and green LEDs\n"
printf "... and button clicks should change the rate ... and printout on the serial port\n"
zigem compile -f em.core/em.examples.combo/Ex01_TickerP.em.zig -l
read -p "Once ready, press enter to exit the tests"

popd > /dev/null

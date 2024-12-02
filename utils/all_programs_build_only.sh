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

Help()
{
   # Display Help
   echo "Run all programs build-only tests"
   echo
   echo "options:"
   echo "c     Compare this run's results with prior results"
   echo "m     Use most recent results as prior results"
   echo "h     Print this Help."
   echo
}

compare=
useMostRecent=
while getopts ":hcm" option; do
   case $option in
      h)
         Help
         exit;;
      c)
         compare="true";;
      m)
         useMostRecent="true";;
     \?)
         echo "Error: Invalid option"
         exit 1;;
   esac
done

pushd ${SCRIPT_DIR}/../workspace > /dev/null

mrFilename=all_programs_build_only_most_recent.log
lrFilename=all_programs_build_only_last.log
if [ "$useMostRecent" == "true" ] && [ ! -f "${SCRIPT_DIR}/${mrFilename}" ]; then
  echo "Error: No most recent results to use.  Run without -c and -m."
  exit 1
elif [ "$useMostRecent" == "true" ]; then
  if [ -f "${SCRIPT_DIR}/${lrFilename}" ]; then
    mv ${SCRIPT_DIR}/${lrFilename} ${SCRIPT_DIR}/${lrFilename}~
  fi
  mv ${SCRIPT_DIR}/${mrFilename} ${SCRIPT_DIR}/${lrFilename}
fi
if [ "$compare" == "true" ] && [ ! -f "${SCRIPT_DIR}/${lrFilename}" ]; then
  echo "Error: No last results to compare.  Run with -c and -m to use most recent results."
  exit 1
fi
rm -f ${SCRIPT_DIR}/${mrFilename}
printf "\n${Green}>>> Building all setups / programs in em.core <<<${Color_Off}\n"
printf "| Setup                 | Program                                               | text  | const | data  | bss   |\n"
printf "| --------------------- | ----------------------------------------------------- | ----- | ----- | ----- | ----- |\n"
printf "| Setup                 | Program                                               | text  | const | data  | bss   |\n" >> ${SCRIPT_DIR}/${mrFilename}
printf "| --------------------- | ----------------------------------------------------- | ----- | ----- | ----- | ----- |\n" >> ${SCRIPT_DIR}/${mrFilename}
chips=ti.cc23xx
programs=$(find em.core -name '*P.em.zig' | sort)
for chip in $chips; do
  setups=$(find ${chip} -name 'setup-*.ini' | sort)
  for setup in $setups; do
    setup2=$(echo -n $setup | sed 's/\//:\/\//' | sed 's/setup-\|\.ini//g')
    for program in $programs; do
      result=$(${SCRIPT_DIR}/../zig-out/bin/zigem compile --setup ${setup2} -f ${program} | grep 'image size:' | awk '{print $4, $7, $10, $13}' | sed 's/(/\t| /g' | sed 's/)//g')
      printf '| %s\t| %-50s %s\t|\n' "$setup2" "$program" "$result"
      printf '| %s\t| %-50s %s\t|\n' "$setup2" "$program" "$result" >> ${SCRIPT_DIR}/${mrFilename}
    done
  done
done
printf "${Green}>>> Building all setups / programs in em.core complete <<<${Color_Off}\n"
if [ "$compare" == "true" ] && [ -f ${SCRIPT_DIR}/${mrFilename} ] && [ -f ${SCRIPT_DIR}/${lrFilename} ]; then
  printf "\n${Green}>>> Difference from last results <<<${Color_Off}\n"
  diff ${SCRIPT_DIR}/${lrFilename} ${SCRIPT_DIR}/${mrFilename}
  printf "${Green}>>> Difference from last results complete <<<${Color_Off}\n"
fi

popd > /dev/null

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

pushd ${SCRIPT_DIR}/../workspace > /dev/null

printf "\n${Green}>>> Building all setups / programs in em.core <<<${Color_Off}\n"
printf "| Setup                 | Program                                               | text  | const | data  | bss   |\n"
printf "| --------------------- | ----------------------------------------------------- | ----- | ----- | ----- | ----- |\n"
chips=ti.cc23xx
programs=$(find em.core -name '*P.em.zig' | sort)
for chip in $chips; do
  setups=$(find ${chip} -name 'setup-*.ini' | sort)
  for setup in $setups; do
    setup2=$(echo -n $setup | sed 's/\//:\/\//' | sed 's/setup-\|\.ini//g')
    for program in $programs; do
      result=$(${SCRIPT_DIR}/../zig-out/bin/zigem compile --setup ${setup2} -f ${program} | grep 'image size:' | awk '{print $4, $7, $10, $13}' | sed 's/(/\t| /g' | sed 's/)//g')
      printf '| %s\t| %-50s %s\t|\n' "$setup2" "$program" "$result"
    done
  done
done
printf "${Green}>>> Building all setups / programs in em.core complete <<<${Color_Off}\n"

popd > /dev/null

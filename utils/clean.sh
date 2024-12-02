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

deep="-d"
deepLong="--deep"
clean=$1

if [ "$clean" != "" ] && [ "$clean" != "$deep" ] && [ "$clean" != "$deepLong" ]; then
    echo "usage:  clean.sh [$deep, $deepLong]"
    echo default clean is zig-em workspace only
    echo $deep or $deepLong cleans zig-build artifacts and zig global cache as well
    exit 1
fi

printf "\n${Green}>>> Clean Workspace <<<${Color_Off}\n"
echo "    Clean workspace"
rm -rf $SCRIPT_DIR/../workspace/{zigem,.zigem-main.zig,.zigem-check.zig}

if [ "$clean" != "" ] ; then
    echo "    Clean zig build artifacts"
    rm -rf $SCRIPT_DIR/../{.zig-cache,zig-out,zigem}

    echo "    Clean zig global cache"
    rm -rf $HOME/.cache/zig
fi
printf "${Green}>>> Clean Workspace complete <<<${Color_Off}\n"

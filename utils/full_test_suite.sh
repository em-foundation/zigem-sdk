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

printf "\nFull test suite completed\n"

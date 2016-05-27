#!/bin/bash
# Run make commands in given directories with set targets
# 2015 Bryzgalov Peter @ AICS RIKEN

# Possible targets: clean tau tau-comp tauscorep scorep
# See makeMakefile.sh for details

source ./config.sh

if [ $1 ]
then
    if [ $1 == "clean" ]
    then
        echo -e "\e[34mCleaning \e[0m"
        for dir in "${directs[@]}"
        do
            cd $dir
            pwd
            make clean
            cd ..
        done
        echo "Done."
        exit 0
    fi
fi

for dir in "${directs[@]}"
do
    for target in "${targets[@]}" 
    do
        echo -e "\e[32m###\n# $dir  $target   \n###\e[0m"
        cd $dir
        pwd 
        make $target
        cd ..
    done
done

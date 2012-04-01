#!/bin/bash
# This script prepends a file to a set of files. 
# Syntax:
# prepend.sh FILE [FILE]
# where file1 contains the text to prepend and file2 onwards are the 
# files to prepend it to.
#
# E.g. the following would prepend a copyright notice to every C source
# and include file:
# prepend.sh copyrightnotice *.c *.h 

if [ -z $1 ]; then
    echo Usage: $(basename $0) FILE [FILE]  
    exit 1
fi

tmp=("$@")
args=("${tmp[@]:1}")

TFILE="/tmp/$(basename $0).$$.tmp"

for i in ${args[@]}; do
    cat $1 $i > $TFILE 
    cp $TFILE $i
done

rm $TFILE

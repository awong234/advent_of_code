#!/bin/bash
verbosity=$1
if [ -z $verbosity ]
then
    verbosity=0
fi
awk -v verbose=$1 -f solution.awk input.txt
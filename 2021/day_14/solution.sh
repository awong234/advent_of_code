#!/bin/bash

file=$1
if [ -z $file ]
then
    file="sample_input.txt"
fi

s1=$(awk -v N=10 -f solution.awk $file)
echo "Solution 1 is: $s1"
s2=$(awk -v N=40 -f solution.awk $file)
echo "Solution 2 is: $s2"

#!/bin/bash

file=$1

if [ -z $file ]
then
    file="input_pgr.txt"
fi

first=$(awk -f solution_01.awk $file | sort | uniq | wc -l)
echo "First answer is $first"

awk -f solution_02.awk $file

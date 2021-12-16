#!/bin/bash

first=$(awk -f solution_01.awk $1 | sort | uniq | wc -l)
echo "First answer is $first"

awk -f solution_02.awk $1

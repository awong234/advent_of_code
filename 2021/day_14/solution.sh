#!/bin/bash

file=$1
if [ -z $file ]
then
    file="sample_input.txt"
fi

newseq=$(awk -v N=10 -f solution1.3.awk $file)
awk '
BEGIN {
    FS = ""
}
{
    for (i=1; i<=NF; i++) {
        letters[$i]++
    }
}
END {
    for (i in letters) {
        print letters[i]
    }
}
' <<< $newseq | sort -n > tmp.txt


max=$(tail tmp.txt -n 1)
min=$(head tmp.txt -n 1)
rm tmp.txt

echo "Solution 1: " $(($max - $min))

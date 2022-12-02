#!/bin/bash
for i in {1..25}
do
    var=$(printf "%02d\n" $i)
    mkdir "day_$var"
    touch "day_$var/input.txt"
    touch "day_$var/readme.md"
done

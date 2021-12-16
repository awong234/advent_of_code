#!/bin/bash

file=$1
if [ -z $file ]
then
    file="sample_input.txt"
fi

echo $file

init=$(head $file -n 1)
# echo -e "0: $init"
cp $file tmp.txt
newseq=$(awk -f solution1.2.awk tmp.txt)
# echo -e "1: $newseq"
for i in {2..10}
do
    sed -i "1 c\\$newseq" tmp.txt
    newseq=$(awk -f solution1.2.awk tmp.txt)
    # echo -e "$i: $newseq"
done
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
echo $max $min
echo "Solution 1: " $(($max - $min))

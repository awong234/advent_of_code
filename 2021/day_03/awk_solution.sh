#!/bin/bash
# Part 1
awk -f aw_03_01.awk aw_input_03.txt > binaries.txt
i=1
while read p; do
    val[i]=$((2#$p))
    ((i+=1))
done < binaries.txt
echo "Part 1 product is $((${val[1]} * ${val[2]}))"
rm binaries.txt
# Part 2
valid () {
    i=1
    keep=$(awk -v f=$i -v t="$1" -f aw_03_02.awk aw_input_03.txt)
    # echo $keep
    awk -v keep=$keep 'BEGIN {FS=""} {if ($1 == keep) print $0}' aw_input_03.txt > valid_$1.txt
    for i in {2..12}
    do
        keep=$(awk -v t="$1" -v f=$i -f aw_03_02.awk valid_$1.txt)
        # echo $keep
        awk -v keep=$keep -v f=$i 'BEGIN {FS=""} {if ($f == keep) print $0}' valid_$1.txt > tmp.txt
        mv tmp.txt valid_$1.txt
        n=$(wc -l valid_$1.txt | cut -d ' ' -f1)
        if [ $n -eq 1 ]
        then
            break
        fi
    done
}

valid "o2"
valid "co2"
val[1]=$((2#$(cat valid_o2.txt)))
val[2]=$((2#$(cat valid_co2.txt)))
echo "Part 2 product is $((${val[1]} * ${val[2]}))"
rm valid*.txt

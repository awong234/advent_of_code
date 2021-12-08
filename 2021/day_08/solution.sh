#!/bin/bash
awk -f solution_02.awk input_pgr.txt 2>/dev/null | tee tmp.txt
echo ""
echo "^^^^^^^ Part II output ^^^^^^^"
echo ""
awk -f solution_01.awk input_pgr.txt 2>/dev/null
awk 'BEGIN{sum=0} /Decoded/ {sum+=$4} END{ print "Part II solution is:\t" sum }' tmp.txt
rm tmp.txt
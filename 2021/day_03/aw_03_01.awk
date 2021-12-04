BEGIN {
    FS=""
    ORS=""
}
{
    for (i = 1; i <= NF; i++)
        if ($i == 1) {
            tally[i]+=1
        }
}
END {
    for (i = 1; i <= NF; i++)
       if (tally[i] > (FNR / 2)) {
           print 1
       } else {
           print 0
       }
    print "\n"
    for (i = 1; i <= NF; i++)
       if (tally[i] < (FNR / 2)) {
           print 1
       } else {
           print 0
       }
    print "\n"
}

BEGIN {
    FS="[ \|]"
    OFS=","
    ORS=""
    tally=0
}
{
    $1=$1
    # print $0
    # $1:$10 are the unique signal patterns. $13:$16 are the digit codes
    # Tally frequencies
    for (i=13; i<=16; i++) {
        l = length($i)
        if (l == 2 || l == 3 || l == 4 || l == 7) {
            tally+=1
        }
    }
}
END {
    print "Part I solution is:\t" tally
}
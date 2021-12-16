BEGIN {
    FS=""
    # ORS=""
}
{
    if (NR == 1) {
        seq=$0
        l = length(seq)
        for (i=1; i<=NF; i++) {
            letters[$i]++
        }
        # for (i in letters) {
        #     print "INIT LETTER COUNT: " i, letters[i]
        # }
        for (i=1; i<l; i++) {
            to_match = substr(seq, i, 2)
            pairs[to_match]++
        }
        # for (i in pairs) {
        #     print "INIT PAIR COUNT: " i, pairs[i]
        # }
        # print "Init sequence: " seq " length " length(seq)
    }
    else if ($0 != "") {
        FS=" -> "
        $0=$0
        insertion[$1] = $2
    }
}
END {
    for (times=1; times<=N; times++) {
        # print "--------------"
        # print "ITER", times
        # print "--------------"
        # Reset newpairs array
        split("", newpairs)
        for (p in pairs) {
            # print "PAIR", p, pairs[p]
            if (pairs[p] > 0) {
                ins = insertion[p]
                # print "Insertion letter is: " ins
                # Add the new letter to the count; as many as there are pairs
                add = pairs[p]
                # print "Adding " add " to " ins
                letters[ins]+=add
                # for (i in letters) {
                #     print i, letters[i]
                # }
                # Develop the new pairs
                split(p, newsplit, "")
                newpair1 = sprintf("%s%s", newsplit[1], ins)
                newpair2 = sprintf("%s%s", ins, newsplit[2])
                newpairs[newpair1]+=add
                newpairs[newpair2]+=add
                newpairs[p]-=add
                # print "NEW PAIRS:", newpair1, newpair2
                # print "DROPPED PAIR", p
                # print ""
            }
        }
        for (p in newpairs) {
            pairs[p] = pairs[p] + newpairs[p]
        }
    }
    # for (p in pairs) {
    #     print p, pairs[p]
    # }
    n=asort(letters, letsort)
    print letsort[n] - letsort[1]
}

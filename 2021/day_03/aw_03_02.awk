BEGIN {
    FS=""
}

{
    if ($f == 1) {
        tally+=1
    }
}

END {
    if (t == "o2") {
        if (tally < (FNR / 2)) {
            print 1
        } else {
            print 0
        }
    }
    if (t == "co2") {
        if (tally >= (FNR / 2)) {
            print 1
        } else {
            print 0
        }
    }

}

function test(sym) {
    if (verbose > 2) print "\nTESTING CLOSE input " sym "; close index is "c
    for (v=c-1; v>=1; v--) {
        if (verbose > 2) print "\nCurrent symbol is " sym ", expected " clos[openorder[v]] ", last open was " openorder[v]
        if (verbose > 3) {
            print "\nv is "v
            print "\nc is "c
            print "\nopen order manual is"
            print "\n1:" openorder[1]
            print "\n2:" openorder[2]
            print "\n3:" openorder[3]
            print "\n..."
            print "\nv:"openorder[v]
        }

        if (openorder[v] == open[sym]) {
            if (verbose > 2) print "\nOK: Deleting " openorder[v] " index " v "; " open[sym] " matches " openorder[v]
            delete openorder[v]
            return 0
        } else {
            if (verbose > 2) print "\nERROR: Current symbol is " sym ", expected " clos[openorder[v]] ", last open was " openorder[v] "\n"
            err[sym]+=1
            return 1
        }
    }
}

BEGIN {
    FS=""
    OFS=","
    ORS=""
    # For looking up the open / close symbol given the other
    open["]"] = "["
    open["}"] = "{"
    open[")"] = "("
    open[">"] = "<"
    clos["["] = "]"
    clos["{"] = "}"
    clos["("] = ")"
    clos["<"] = ">"

    # part I score to tally
    err["]"] = 0
    err["}"] = 0
    err[")"] = 0
    err[">"] = 0

    # part II score -- points by symbol
    split("", rem) # initialize empty array for rem, to score remaining close symbol points
    rem_points[")"] = 1
    rem_points["]"] = 2
    rem_points["}"] = 3
    rem_points[">"] = 4
    NI=0 # Keep track of number incompletes, to find middle index later on
}

{
    if (verbose > 0) {
        print "\n"
        print "\nLine: "NR
        print "\n""==================="
    }
    # Reset counter for each line
    c=0
    # Reset line-error for each line
    t=0
    # Score the line's remainder score
    rem_line=0
    # reset openorder to empty array; openorder is the sequential order of open symbols
    split("", openorder)
    # For each symbol, keep track of opens, closes
    for (i=1;i<=NF;i++) {
        if (verbose > 1) {
            printf("\n%02d ", i)
            for (k in openorder) {
                print openorder[k]
            }
        }
        # Increment -- add open symbols to array
        for (var in open) {
            if ($i == open[var]) {
                openorder[c]=$i
                c+=1
                break
            }
        }
        # Decrement -- remove close symbols from array if not corrupted.
        for (var in clos) {
            if ($i == clos[var]) {
                t+=test($i)
                c-=1
                break
            }
        }
    }

    if (c > 0 && t == 0) {
        NI+=1
        if (verbose > 0) print "\n  INCOMPLETE"
        if (verbose > 1) {
            print "open order is: "
            for (v in openorder) {
                print openorder[v]
            }
            print "\nREMAINING TO CLOSE:"
        }

        for (v=c-1; v>=0; v--) {
            if (verbose > 1) print "\n"clos[openorder[v]] " score = " rem_line
            rem_line = (5 * rem_line) + rem_points[clos[openorder[v]]]
            if (verbose > 1) print " x 5 + " rem_points[clos[openorder[v]]] " --> " rem_line
        }
        rem[NI]=rem_line
    } else {
        if (verbose > 0) print "\n  CORRUPTED"
    }

}
END {
    # Round middle value
    middle=NI/2
    middle = middle == int(middle) ? middle : int(middle) + 1
    print "\n"
    if (verbose > 0) print "\nfinal c " c
    print "\nSolution 1 is: " err[")"] * 3 + err["]"] * 57 + err["}"] * 1197 + err[">"] * 25137
    if (verbose > 0) print "\nmiddle index is: " middle
    if (verbose > 0) print "\nSorting part II line scores"
    asort(rem)
    print "\nSolution 2 is: " rem[middle]
}
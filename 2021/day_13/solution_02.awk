function fold(fold_index, x) {
    out = fold_index - (x - fold_index)
    if (x > fold_index) {
        return out
    } else {
        return x
    }
}

function print_matrix(x, y) {
    OFS=""

}

BEGIN {
    FS="[, =]"
    max_x = 0
    max_y = 0
}
/fold/ {
    digits_cnt++
    digits[digits_cnt] = $4
    directions[digits_cnt] = $3
}

/[0-9]+,[0-9]+/ {
    x[NR] = $1
    y[NR] = $2
}

END {
    for (i in digits) {
        val = digits[i]
        dir = directions[i]
        for (j in x) {
            if (dir == "y") {
                y[j] = fold(val, y[j])
            } else {
                x[j] = fold(val, x[j])
            }
        }
    }

    # Get x and y range
    max_x = 0
    for (i in x) {
        if (x[i] > max_x) {
            max_x = x[i]
        }
    }
    max_y = 0
    for (i in y) {
        if (y[i] > max_y) {
            max_y = y[i]
        }
    }

    ORS=" "
    print ""

    for (i=0; i<=max_y; i++) {
        for (j=0; j<=max_x; j++) {
            for (xi in x) {
                if (x[xi] == j && y[xi] == i) {
                    print_hash = 1
                    break
                } else {
                    print_hash = 0
                }
            }
            if (print_hash) {
                print "#"
            } else {
                print "."
            }
        }
        print "\n"
    }
}

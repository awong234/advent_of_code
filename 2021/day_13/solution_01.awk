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
    val = digits[1]
    dir = directions[1]
    for (j in x) {
        if (dir == "y") {
            y[j] = fold(val, y[j])
        } else {
            x[j] = fold(val, x[j])
        }
    }

    for (i in x) {
        print x[i], y[i]
    }
}

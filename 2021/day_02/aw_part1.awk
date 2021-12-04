# Part 1

BEGIN {
    depth=0
    x=0
}
/forward/ {
    x+=$2
}
/down/ {
    depth+=$2
}
/up/ {
    depth-=$2
}
END {
    print "depth is " depth
    print "pos is " x
    print "product is " depth * x
}

# Part 2

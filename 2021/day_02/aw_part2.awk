BEGIN {
    depth=0
    aim=0
    x=0
}
/forward/ {
    x+=$2
    depth+=$2*aim
}
/up/ {
    aim-=$2
}
/down/ {
    aim+=$2
}
END {
    print "x is " x
    print "depth is " depth
    print "final aim is " aim
    print "product is " x * depth
}

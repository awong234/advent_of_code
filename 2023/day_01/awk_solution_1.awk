BEGIN {
    sum=0
}
{
    gsub("[a-z A-Z]", "")
    first = substr($0,1,1)
    last = substr($0,length,length)
    digit = first last
    sum+=digit
}
END {
    print(sum)
}

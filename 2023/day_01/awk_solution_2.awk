BEGIN {
    sum=0
    number_names = "one two three four five six seven eight nine"
    split(number_names, tmp)
    i=1
    for (i in tmp) {
        number_array[tmp[i]] = i
    }
}
{
    print "NEW LINE: " $0
    start = 1
    len = 1
    collect = ""
    for (i=1; i<=length; i++) {
        # print "ITER " i
        word = substr($0, start, len)
        # print "Word so far is: " word
        if (word ~ /[[:digit:]]/) {
            # print "found digit"
            start=i+1
            len = 1
            gsub(/[a-zA-Z]/, "", word)
            collect = sprintf("%s%s", collect, word)
            # print "Collection so far is: " collect
        }
        else if (word ~ /(one|two|three|four|five|six|seven|eight|nine)/) {
            # print "found number"
            start=i+1
            len = 1
            word_start = match(word, /(one|two|three|four|five|six|seven|eight|nine)/, arr)
            integer = number_array[arr[1]]
            collect = sprintf("%s%s", collect, integer)
            # print "Collection so far is: " collect
        }
        else {
            len++
        }
    }
    # print "END COLLECTION:" collect
    number = substr(collect, 1, 1) substr(collect, length(collect), length(collect))
    print number
    sum += number
}
END {
    print "TOTAL SUM IS: " sum
}

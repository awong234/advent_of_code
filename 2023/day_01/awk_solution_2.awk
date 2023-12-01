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
    start = 1
    len = 1
    while(1) {
        word = substr($0, start, len)
        if (word ~ /[[:digit:]]/) {
            gsub(/[a-zA-Z]/, "", word)
            collect_first = word
            start=i+1
            break
        }
        else if (word ~ /(one|two|three|four|five|six|seven|eight|nine)/) {
            word_start = match(word, /(one|two|three|four|five|six|seven|eight|nine)/, arr)
            integer = number_array[arr[1]]
            collect_first = integer
            start=i+1
            break
        }
        else {
            len++
        }
    }
    # Find last number
    start = length
    len = 1
    while(1) {
        word = substr($0, start, len)
        if (word ~ /[[:digit:]]/) {
            gsub(/[a-zA-Z]/, "", word)
            collect_second = word
            break
        }
        else if (word ~ /(one|two|three|four|five|six|seven|eight|nine)/) {
            word_start = match(word, /(one|two|three|four|five|six|seven|eight|nine)/, arr)
            integer = number_array[arr[1]]
            collect_second = integer
            break
        } else {
            start--
            len++
        }
    }
    number = collect_first collect_second
    sum += number
}
END {
    print "TOTAL SUM IS: " sum
}

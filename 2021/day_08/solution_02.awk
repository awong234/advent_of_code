function bracket(letters) {
    return "["letters"]"
}

BEGIN {
    FS="[ \|]"
}
# Line by line deduce configuration

# Determine letters for 1, this will have two digits
# Determine letters for 7, this will have three digits
# Determine letters for 4, this will have four digits
# Determine letters for 8, this will have seven digits
# Determine letters for the rest by removing intersections and finding what's removed.
# The five digit numbers are thus 2, 3, 5
    # If 7's letters are removed from 3's, 3 are removed.
    # If 7's letters are removed from 2's or 5's, two letters are removed.
        # If 4's letters are removed from 2's, two letters are removed.
        # If 4's letters are removed from 3's, three letters are removed.
# The six digit numbers are 0, 6, 9
    # If 7's letters are removed from 6's, two letters are removed.
    # If 7's letters are removed from 9's or 0's, three letters are removed.
        # If 4's letters are removed from 9, four letters are removed.
        # If 4's letters are removed from 0, three letters are removed.
# EX:
#

#  aaaa                            aaaa                           ----
# .    c                          .    c                         .    -
# .    c                          .    c        results in       .    -
#  dddd      remove 7's letters    ....       three removals      dddd
# .    f                          .    f                         .    -
# .    f                          .    f                         .    -
#  gggg                            ....                           gggg

{
    ORS="\n"
    print "\n"
    print NR
    print "=================="
    # First pass -- find the obvious ones
    for (i=1; i<=10; i++) {
        if (length($i) == 2) {
            print "8 is " $i
            one = $i
        }
        else if (length($i) == 3) {
            print "7 is " $i
            seven = $i
        }
        else if (length($i) == 4) {
            print "4 is " $i
            four = $i
        }
        else if (length($i) == 7) {
            print "8 is " $i
            eight = $i
        }
    }
    print "Encoded digits are: " $13, $14, $15, $16
    ORS=""
    print "Decoded digits are: "
    for (i=13; i<=16; i++) {
        if (length($i) == 2) {
            print "1"
        }
        else if (length($i) == 3) {
            print "7"
        }
        else if (length($i) == 4) {
            print "4"
        }
        else if (length($i) == 7) {
            print "8"
        }
        else if (length($i) == 6) {
            letters = $i
            # Remove seven's letters; if 2 are removed, the answer is 6
            n=gsub(bracket(seven), "", letters)
            if (n==2) {
                print "6"
            }
            # If more than 2 are removed, the answer is either 0 or 9
            else if (n > 2) {
                letters = $i
                n=gsub(bracket(four), "", letters)
                # If 3 are removed, then the answer is 0
                if (n==3) {
                    print "0"
                }
                else if (n == 4) {
                    print "9"
                } else {
                    print "!"
                }
            }
            else {
                print "!"
            }

        }
        else if (length($i) == 5) {
            # Either 2, 3, or 5.
            letters=$i
            # Remove seven's letters; if 2 letters are removed it's 2 or 5; if 3 are removed it's 3
            n=gsub(bracket(seven), "", letters)
            if (n==3) {
                print "3"
            }
            else if (n==2){
                # Remove four's letters;
                letters=$i
                n=gsub(bracket(four), "", letters)
                # if 2 are removed it's 2;
                if (n == 2) {
                    print "2"
                # if 3 are removed it's 5
                } else if (n == 3) {
                    print "5"
                } else {
                    print "?"
                }
            }

        }
        else {
            print "#"
        }
    }
    print("\n")
}
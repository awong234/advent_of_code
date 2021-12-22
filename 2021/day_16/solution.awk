function convert_bin(bin) {
    # Calls out to bash to convert binary to decimal.
    res=""
    cmd = "echo $((2#" bin "))"
    cmd | getline res
    close(cmd)
    return res
}

function decode_literal() {
    # Decode literal
    # print "DECODING LITERAL AT MARKER " marker
    sym = ""
    sym_intern = ""
    cur = binsplit[marker]
    terminated = 0
    while (cur != "") {
        cur = binsplit[marker]
        # print "Current number: " cur ". Marker " marker
        if (cur == 1 && !terminated) {
            # Accumulate the literal until 0
            # print "term status: " terminated
            marker++ # Skip to the next number
            sym_intern = accumulate(3) # Start an empty string
            sym = sym sprintf("%04d", sym_intern) # Pad the left with 0's
            # print sym_intern
        } else if (cur == 0 && !terminated) {
            # print "term status: " terminated
            # Terminate the literal
            terminated = 1
            marker++
            sym_intern = accumulate(3)
            sym = sym sprintf("%04d", sym_intern)
            # print sym_intern
            # print sym
            res = convert_bin(sym)
            # print "reached end of literal"
        } else if (terminated) {
            # print "term status: " terminated
            # print "breaking out"
            break
        }
    }
    # print "LITERAL IS " res
    return res
}

function decode_subpacket_l(n,    sym, sym_intern) {
    # Decode subpacket length.
    # Increments marker by n units via `accumulate`.
    # Accumulates the next n digits and returns the binary converted to decimal.
    sym = ""
    sym_intern = accumulate(n)
    sym = sym sprintf("%s", sym_intern)
    subpacket_l = convert_bin(sym)
    return subpacket_l
}

function aggregate_subpackets(type, subpacket_type, limit,   res_arr, res_min, res_max, res, packets_done) {
    res_min = -log(0)
    res_max = log(0)
    packets_done = 0
    if (type == 1) res = 1
    if (subpacket_type == "l") {
        test = marker < limit
    } else {
        test = packets_done < limit
    }

    while (test) {
        packets_done++
        if (type == 0) {
            # print "TYPE 0: SUM"
            res += decode_packet(depth+1)
        } else if (type == 1) {
            # print "TYPE 1: PROD"
            res *= decode_packet(depth+1)
        } else if (type == 2) {
            # print "TYPE 2: MIN"
            res = decode_packet(depth+1)
            if (res < res_min) {
                res_min = res
            }
        } else if (type == 3) {
            # print "TYPE 3: MAX"
            res = decode_packet(depth+1)
            if (res > res_max) {
                res_max = res
            }
        } else if (type == 5) {
            # print "TYPE 5: GT"
            res_arr[packets_done] = decode_packet(depth+1)
            if (packets_done == 2) {
                if (res_arr[1] > res_arr[2]) {
                    res = 1
                } else {
                    res = 0
                }
            }
        } else if (type == 6) {
            # print "TYPE 6: LT"
            res_arr[packets_done] = decode_packet(depth+1)
            if (packets_done == 2) {
                if (res_arr[1] < res_arr[2]) {
                    res = 1
                } else {
                    res = 0
                }
            }
        } else if (type == 7) {
            # print "TYPE 7: EQ"
            res_arr[packets_done] = decode_packet(depth+1)
            if (packets_done == 2) {
                if (res_arr[1] == res_arr[2]) {
                    res = 1
                } else {
                    res = 0
                }
            }
        }
        if (subpacket_type == "l") {
            test = marker < limit
        } else {
            test = packets_done < limit
        }
    }

    if (type == 2) res = res_min
    if (type == 3) res = res_max
    # print "RETURNING RES " res
    return(res)
}

function decode_subpackets(type,     end, packets_done, subpacket_n) {
    # Decode literal while marker < n.
    # print "DECODING OPERATOR PACKET, SUBPACKET LENGTH"
    cur = binsplit[marker]
    # print "Current number: " cur ". Marker " marker " of " length(bin)
    if (cur == 0) {
        marker++
        # next 15 bits indicate length of subpacket
        subpacket_l = decode_subpacket_l(14)
        # print "SUBPACKET LENGTH " subpacket_l
        end = marker + subpacket_l
        # print "Subpacket from " marker " to " end
        res = aggregate_subpackets(type, "l", end)
    } else {
        # Next 11 bits indicate number of subpackets
        marker++
        subpacket_n = decode_subpacket_l(10)
        # print "NUMBER SUBPACKETS " subpacket_n
        res = aggregate_subpackets(type, "n", subpacket_n)
    }
    return res
}

function accumulate(n,    sym_intern, bars, dashes) {
    # Accumulates the next n binary digits into a string and returns the string.
    # Implicitly increments global marker value!
    # printf  "%0.0f finished\r", 10 * (marker / length(bin))
    nbars = 30 * (marker / length(bin))
    ndash = 30 - nbars
    bars = ""
    dashes = ""
    for (i=0; i<=nbars; i++) {
        bars = bars "="
    }
    for (i=0; i<=ndash; i++) {
        dashes = dashes " "
    }
    print "|" bars dashes "| " 100 * marker / length(bin) "%   "
    sym_intern = "" # Start an empty string
    for (i=marker; i<=(marker+n); i++) {
        sym_intern = sym_intern binsplit[i] # Concatenate the next n digits
    }
    marker = marker + n + 1 # Increment the marker n + 1 units
    return sym_intern
}

function decode_packet(depth,    v, t) {
    # print "DECODING PACKET; depth:", depth, "; marker:", marker
    v = ""
    t = ""
    v = accumulate(2)
    t = accumulate(2)
    version = convert_bin(v)
    vsum+=version # Increment version sum for part I
    type = convert_bin(t)
    # print "version " version
    # print "type " type
    if (type == 4) {
        res = decode_literal()
    } else {
        res = decode_subpackets(type)
    }
    return res
}

BEGIN {
    binary["0"] = "0000"
    binary["1"] = "0001"
    binary["2"] = "0010"
    binary["3"] = "0011"
    binary["4"] = "0100"
    binary["5"] = "0101"
    binary["6"] = "0110"
    binary["7"] = "0111"
    binary["8"] = "1000"
    binary["9"] = "1001"
    binary["A"] = "1010"
    binary["B"] = "1011"
    binary["C"] = "1100"
    binary["D"] = "1101"
    binary["E"] = "1110"
    binary["F"] = "1111"

    FS=""
    ORS="\r"
}

{
    for (i=1; i<=NF; i++) {
        bin = bin binary[$i]
    }
    # print bin
    # print length(bin)
}

END {
    split(bin, binsplit, "")
    marker=1
    decode_packet(1)
    ORS="\n"
    print "\n"
    print "Version sum is " vsum
    print "Pt. II result is " res
}

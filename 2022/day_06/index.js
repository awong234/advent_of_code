import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()
var datalines = await input_data()
record_input_data(datalines)

// Problem 1

function tabulate_letters (string) {
    var str_array = string.split("")
    var unique_letters = Array.from(new Set(str_array))
    // Go through each letter and tabulate
    var tab = unique_letters.map(letter => {
        var matches = str_array.filter(v => v == letter)
        var n = matches.length
        return({"letter": letter, "n": n})
    })
    return(tab)
}

function get_repeats (table) {
    return(table.filter(v => v.n > 1).map(v => v.letter))
}

function analyze1 (datastring) {
    var i = 0
    while (true) {
        var unit = datastring.slice(i, i+4)
        var table = tabulate_letters(unit)
        var repeated_letters = get_repeats(table)
        if (repeated_letters.length > 0) {
            i++
        } else {
            return({"index": i+4, "letters": unit})
        }
    }
}

var ans1 = analyze1(datalines)

var answerbox = document.getElementById("output-1").appendChild(document.createElement("pre"))
answerbox.append(`Position: ${ans1.index}, Letters: ${ans1.letters}`)

async function viz1 (datastring) {
    var i = 0
    const svg = d3.select("#dynamic-1").append("svg")
        .attr("width", 300)
        .attr("height", 150)
        // .attr("translate", `translate(50px, 150px)`)
    const ans_index = document.getElementById("output-1-position")
    const ans_letters = document.getElementById("output-1-letters")
    const letter_buffer = 10
    while (true) {
        var unit = datastring.slice(i, i + 4)
        var unit_extended
        if (i < 4) {
            unit_extended = datastring.slice(0, i + 10)
            unit_extended = " ".repeat(4-i) + unit_extended
        } else {
            unit_extended = datastring.slice(i - 4, i + 10)
        }

        var letters = unit_extended.split("")
        var letters_obj = letters.map((d,i) => {
            return({"pos": i, "letter": d, "focus": i >= 4 & i < 8})
        })
        var table = tabulate_letters(unit)
        var repeated_letters = get_repeats(table)
        if (repeated_letters.length > 0) {
            svg.selectAll('text')
                .data(letters_obj)
                .join('text')
                .attr('y', 15)
                .transition()
                .attr('x', (d, i) => i * letter_buffer)
                .attr('fill', (d, i) => d.focus === 0 ? 'gray' : 'blue')
                .text(d => d.letter)
            i++
        } else {
            svg.selectAll('text')
                .data(letters_obj)
                .join('text')
                .attr('y', 15)
                .transition()
                .attr('x', (d, i) => i * letter_buffer)
                .attr('fill', (d, i) => d.focus === 0 ? 'gray' : 'blue')
                .text(d => d.letter)
            break
        }
        ans_index.innerHTML = i+4
        ans_letters.innerHTML = unit
        await new Promise(r => setTimeout(r, 30));
    }
}

viz1(datalines)

// Problem 2

function analyze2 (datastring) {
    var i = 0
    while (true) {
        var unit = datastring.slice(i, i + 14)
        var table = tabulate_letters(unit)
        var repeated_letters = get_repeats(table)
        if (repeated_letters.length > 0) {
            i++
        } else {
            return ({ "index": i + 14, "letters": unit })
        }
    }
}

var ans2 = analyze2(datalines)

answerbox = document.getElementById("output-2").appendChild(document.createElement("pre"))
answerbox.append(`Position: ${ans2.index}, Letters: ${ans2.letters}`)

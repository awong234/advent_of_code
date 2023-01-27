import { parse_readme, input_data, record_input_data } from "../common.js";
import { scaleOrdinal } from "https://cdn.skypack.dev/d3-scale@4";

parse_readme();

var datalines = await input_data();

record_input_data(datalines);

function parse_data (datalines) {
    // Read until blank line
    var data = datalines.split("\n")
    var blank_pos = data.findIndex(x => x === "")

    function parse_crate_data(data) {
        var crate_data = data.filter((_, i) => i < blank_pos - 1) // Minus 1 because we don't care about the literal numbers beneath the crates
        // Get the number of crate columns; take the max of the numeric indexes on the line before the blank
        var crate_idx = data.filter((_, i) => i == blank_pos - 1)[0]
        var ncolumns = Math.max(...crate_idx.replace(/ /g, "").split(""))
        // Get the positions of the crate letters by getting the position of the indices
        var crate_positions = Array(ncolumns).fill(0)
        for (let i = 0; i < ncolumns; i++) {
            crate_positions[i] = crate_idx.split("").findIndex(e => e == i + 1)
        }
        // Create an array of arrays; first level is crate columns, second level is contents of each column
        var crates = Array(ncolumns)
        for (let p in crate_positions) {
            let text_column = crate_positions[p]
            var crate_column_contents = Array(blank_pos - 2)
            for (let i = 0; i < crate_data.length; i++) {
                crate_column_contents[i] = crate_data[i][text_column]
            }
            crates[p] = crate_column_contents.reverse().filter(v => v != " " & v != undefined) // Reverse to make use of pop/push
        }
        return(crates)
    }

    function parse_move_data(data) {
        var move_data = data.filter((e, i) => i > blank_pos)
        move_data.pop() // Remove last empty row
        move_data = move_data.map(e => {
            var split = e.split(" ")
            var instr = {
                "amount": split[1],
                "source": split[3],
                "dest":   split[5]
            }
            return(instr)
        })
        return (move_data)
    }

    var crates = parse_crate_data(data)
    var moves  = parse_move_data(data)

    // console.log(crates)
    // console.log(moves)

    return({"crates": crates, "instructions": moves})
}

const dimensions = { "height": 300, "width": 500 }
const margin = { "top": 30, "left": 30, "right": 30, "bottom": 30 }
d3.select("#dynamic-1").append('svg').attr('width', dimensions.width).attr('height', dimensions.height).append("g").attr("transform", `translate(${margin.left}, ${margin.right})`).attr('id', 'svg-1')
d3.select("#dynamic-2").append('svg').attr('width', dimensions.width).attr('height', dimensions.height).append("g").attr("transform", `translate(${margin.left}, ${margin.right})`).attr('id', 'svg-2')

function update_crates (crates, svgid) {
    const svg = d3.select(svgid)
    const crate_columns = Array(crates.length).fill().map((_,i) => i)
    const crate_stack = Array(Math.max(...crates.map(e => e.length))).fill().map((_,i) => i)
    const x = d3.scaleBand().domain(crate_columns).range([0, dimensions.width])
    const y = d3.scaleBand().domain(crate_stack).range([dimensions.height - margin.top, 0])
    var crates_obj = []
    crates.map((column, column_index) => {
        column.map((letter,i) => {
            let obj = {
                "column": column_index,
                "stack" : i,
                "letter": letter
            }
            crates_obj.push(obj)
        })
    })
    // console.log(crates_obj)
    svg.selectAll('text')
        .data(crates_obj)
        .join("text")
        .attr("col", d => d.column)
        .attr("stack", d => d.stack)
        .attr("x", d => x(d.column))
        .attr("y", d => y(d.stack))
        .transition()
        .duration(500)
        .text(d => d.letter)
        .attr("x", d => x(d.column))
        .attr("y", d => y(d.stack))
}

// Iterate over instructions, altering crates at the same time
function operate1 () {
    var parsed = parse_data(datalines)
    var crates = parsed.crates
    var instructions = parsed.instructions
    instructions.map((d) => {
        let amount = d.amount
        let source = d.source - 1
        let dest = d.dest - 1
        for (let i = 0; i < amount; i++) {
            let crates_moving = crates[source].pop()
            crates[dest].push(crates_moving)
        }
    })
    return(crates)
}

var crates_done = operate1()
var ans1 = document.getElementById('output-1')
ans1.innerHTML = crates_done.map(e => e[e.length - 1]).join("")


/* PLOTTING */

var instruction_id = 1
function reset1 () {
    instruction_id = 1
    init_plot1()
}

document.getElementById('button1').onclick = plot1
document.getElementById('reset1').onclick = reset1

function init_plot1() {
    var parsed = parse_data(datalines)
    var crates = parsed.crates
    update_crates(crates, '#svg-1')
    record_instruction('instruction-id-1')
}

init_plot1()

function record_instruction(id) {
    var input = document.getElementById(id)
    input.innerHTML = instruction_id
}

function plot1 () {
    var parsed = parse_data(datalines)
    var crates = parsed.crates
    var instructions = parsed.instructions
    instructions.map((d, i) => {
        if (i < instruction_id) {
            let amount = d.amount
            let source = d.source - 1
            let dest = d.dest - 1
            for (let i = 0; i < amount; i++) {
                let crates_moving = crates[source].pop()
                crates[dest].push(crates_moving)
            }
        }
    })
    update_crates(crates, '#svg-1')
    if (instruction_id <= instructions.length) {
        instruction_id++
        record_instruction('instruction-id-1')
    }
}


function operate2 () {
    var parsed = parse_data(datalines)
    var crates = parsed.crates
    var instructions = parsed.instructions
    instructions.map(d => {
        let amount = d.amount
        let source = d.source - 1
        let dest = d.dest - 1
        let crates_moving = crates[source].splice(-amount, amount)
        crates[dest].splice(crates[dest].length, 0, ...crates_moving)
    })
    return (crates)
}

var crates_done2 = operate2()

var ans2 = document.getElementById('output-2')
ans2.innerHTML = crates_done2.map(e => e[e.length - 1]).join("")

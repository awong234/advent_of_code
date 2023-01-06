// Improve code structure a little bit by using a common.js file
import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()

var datalines = await input_data()
record_input_data(datalines)

// Begin analysis

function split_data (data) {
    var data_split_1, data_split_2
    data_split_1 = data.split('\n')
    data_split_1.pop()
    data_split_2 = data_split_1.map(d => {
        "['1-2', '3-4']"
        var two_parts = d.split(",")
        var four_parts = two_parts.map(d => {
            "[[1,2], [3,4]"
            return d.split("-").map(d => parseInt(d))
        })
        var data_flat = {
            "first_low": four_parts[0][0],
            "first_high": four_parts[0][1],
            "second_low": four_parts[1][0],
            "second_high": four_parts[1][1]
        }
        return data_flat
    })
    return(data_split_2)
}

function analyze1 (data) {
    var data_flat = split_data(data)
    console.log(data_flat)
    var n_fully_contained = 0
    data_flat = data_flat.map((record, i) => {
        var first_fully_contains_second = record.first_low <= record.second_low & record.first_high >= record.second_high
        var second_fully_contains_first = record.first_low >= record.second_low & record.first_high <= record.second_high
        if (first_fully_contains_second || second_fully_contains_first) {
            n_fully_contained++
            record.fully_contained = true
        } else {
            record.fully_contained = false
        }
        record.id = i
        return(record)
    })

    // Plotting
    var svg = d3.select('#dynamic-1').append('svg')

    const margin = { "top": 30, "left": 30, "right": 30, "bottom": 30 },
        width = 600 - margin.left - margin.right,
        height = 20000 - margin.top - margin.bottom

    const datamax_x = d3.max(data_flat, d => d.first_high > d.second_high ? d.first_high : d.second_high)
    const x = d3.scaleLinear().range([margin.left, width/2]).domain([1, datamax_x])
    const y = d3.scaleLinear().range([0, height]).domain([0, d3.max(data_flat, d => d.id)])

    svg.attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + 23 + ")")
        .call(d3.axisLeft(y).tickValues(data_flat.map(d => d.id)))

    svg.append('g').attr("transform", "translate(" + margin.left + "," + 23 + ")").selectAll("path")
        .data(data_flat)
        .enter()
        .append("path")
        .attr("d", d => {
            var path = d3.path()
            path.moveTo(x(d.first_low), y(d.id))
            path.lineTo(x(d.first_high), y(d.id))
            path.moveTo(x(d.second_low), y(d.id+0.2))
            path.lineTo(x(d.second_high), y(d.id+0.2))
            path.closePath()
            return path.toString()
        })
        .attr("stroke", d => d.fully_contained ? 'green' : 'black')

    // var groups = svg.selectAll('groups')
    //     .data(data_flat.slice(0,2))
    //     .enter()
    //     .append("g")
    //     .attr("transform", (d, i) => `translate(30, 23)`)

    svg.append('g').attr("transform", "translate(" + margin.left + "," + 26 + ")").selectAll('text')
        .data(data_flat)
        .enter()
        .append('text')
        .attr('x', d => x(datamax_x + 3))
        .attr('y', d => y(d.id))
        .attr('text-anchor', 'start')
        .attr('style', d => `font-family:Consolas;font-size:0.75em;fill:${d.fully_contained ? 'green' : 'black'};`)
        .text(d => {
            return `[${d.first_low} - ${d.first_high}], [${d.second_low} - ${d.second_high}]`
        })

    return n_fully_contained
}

var ans1 = analyze1(datalines)

function analyze2 (data) {
    var data_flat = split_data(data)
    var n_overlaps = 0
    for (let i = 0; i < data_flat.length; i++) {
        var record = data_flat[i]
        var first_seq_length = record.first_high - record.first_low + 1
        var first_seq = new Set(Array(first_seq_length).fill().map((e,i) => i + record.first_low))
        var second_seq_length = record.second_high - record.second_low + 1
        var second_seq = new Set(Array(second_seq_length).fill().map((e,i) => i + record.second_low))
        var intersection = new Set([...first_seq].filter(d => second_seq.has(d)))
        if (intersection.size > 0) n_overlaps++
    }
    return n_overlaps
}

var ans2 = analyze2(datalines)

function write_answer(elementId, answer) {
    var ans1div = document.getElementById(elementId)
    ans1div.appendChild(document.createElement("p")).append(answer)
}

write_answer('output-1', ans1)
write_answer('output-2', ans2)

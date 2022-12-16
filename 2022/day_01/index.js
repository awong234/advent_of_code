import { text } from "https://cdn.skypack.dev/d3-fetch@3";
import { parse_readme } from "../common.js"

// Analyze dataset -- Part I

parse_readme()

const input = "input.txt";
var elves, maxval, maxid, datalines

const data = await text(input);

function analyze_1 (input) {
    datalines = input.split("\n")
    // console.log(datalines)
    let length = datalines.length
    let elf_id = 1
    let elf_val = 0
    let elf_items = 0
    elves = { elf_id: [], elf_calories: [], elf_items: []}
    for (let i = 0; i < length; i++) {
        if (datalines[i] === "") {
            // console.log(`Elf ${elf_id} had calories ${elf_val}`)
            elves.elf_id.push(elf_id)
            elves.elf_calories.push(+elf_val)
            elves.elf_items.push(+elf_items)
            elf_id += 1
            elf_val = 0
            elf_items = 0
        } else {
            elf_val += +datalines[i]
            elf_items += 1
        }
    }
    maxval = Math.max(...elves.elf_calories)
    maxid = elves.elf_id[elves.elf_calories.indexOf(maxval)]
}

analyze_1(data)

console.log(elves)
var maxval_statement = `Max value is ${maxval.toLocaleString('en-US')}`
console.log(maxval_statement)
var maxid_statement = `Elf with max value is ${maxid}`
console.log(maxid_statement)

var div_input_data = document.getElementById("input-data-1")
div_input_data.appendChild(document.createElement('pre')).append(datalines.join("\n"))

var answer_div = document.getElementById("output-1")
answer_div.appendChild(document.createElement('pre')).append(maxval_statement + "\n" + maxid_statement)

// Analyze -- Part II

var sum

function analyze_2 () {
    // Order elves by calories
    let order = Array.from(Array(elves.elf_calories.length).keys())
        .sort((a, b) => elves.elf_calories[a] > elves.elf_calories[b] ? -1 : (elves.elf_calories[b] > elves.elf_calories[a]) | 0)

    sum = elves.elf_calories[order[0]] + elves.elf_calories[order[1]] + elves.elf_calories[order[2]]
}

analyze_2()

var sum_statement = `The top three elves are carrying ${(sum).toLocaleString('en-US')} calories.`
console.log(sum_statement)

var answer2_div = document.getElementById("output-2")
answer2_div.appendChild(document.createElement('pre')).append(sum_statement)

// Develop graphics for part I and II
// Want a bar chart that sorts by elf ID first, then by value for the second answer.

// sample newdata
// var elves = {"elf_id": [1,2,3], "elf_calories": [100, 200, 300], "elf_items": [10, 20, 30]}

function reshape(data) {
    // Restructure elves data; need one record per row
    let newdata = []
    for (let i = 0; i < data.elf_id.length; i++) {
        let id = data.elf_id[i]
        let cal = data.elf_calories[i]
        let items = data.elf_items[i]
        newdata[i] = { "elf_id": id, "elf_calories": cal, "elf_items": items }
    }
    return(newdata)
}


// set the dimensions and margins of the graph
const margin = { top: 30, right: 30, bottom: 70, left: 60 },
    width = 960 - margin.left - margin.right,
    height = 500 - margin.top - margin.bottom;

const x = d3.scaleBand()
    .range([0, width])
    .padding(0.2)

const y = d3.scaleLinear()
    .range([height, 0])

function plot(d) {

    d3.select("svg").remove()

    var svg = d3.select("body").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform",
            "translate(" + margin.left + "," + margin.top + ")")
        .attr("id", "mainbox")


    x.domain(d.map(function (d) { return d.elf_id; }));
    y.domain([0, d3.max(d, function (d) { return d.elf_calories + 20000; })]);

    // append the rectangles for the bar chart
    svg.selectAll(".bar")
        .data(d)
        .enter().append("rect")
        .attr("class", "bar")
        .attr("x", function (d) { return x(d.elf_id); })
        .attr("width", x.bandwidth())
        .attr("y", function (d) { return y(d.elf_calories); })
        .attr("height", function (d) { return height - y(d.elf_calories); });

    // add the y Axis
    svg.append("g")
        .call(d3.axisLeft(y));
}

function annotate1() {
    // Create an annotation
    let annotations = [{
        note: {
            label: maxval_statement,
            title: "Answer:"
        },
        data: { elf_id: maxid, elf_calories: maxval },
        dx: -50,
        dy: -10
    }]

    let makeAnnotations = d3.annotation()
        .type(d3.annotationLabel)
        .accessors({
            x: d => x(d.elf_id) + margin.left,
            y: d => y(d.elf_calories) + margin.top
        })
        .accessorsInverse({
            elf_id: d => x.invert(d.x),
            elf_calories: d => y.invert(d.y)
        })
        .annotations(annotations)

    d3.select("svg")
        .append("g")
        .attr("class", "annotation-group")
        .call(makeAnnotations)
}

function annotate2() {
    // Create an annotation
    let annotations = [{
        note: {
            label: sum_statement,
            title: "Answer:"
        },
        data: { elf_id: maxid, elf_calories: maxval },
        dx: -50,
        dy: -10
    }]

    let makeAnnotations = d3.annotation()
        .type(d3.annotationLabel)
        .accessors({
            x: d => x(d.elf_id) + margin.left,
            y: d => y(d.elf_calories) + margin.top
        })
        .accessorsInverse({
            elf_id: d => x.invert(d.x),
            elf_calories: d => y.invert(d.y)
        })
        .annotations(annotations)

    d3.select("svg")
        .append("g")
        .attr("class", "annotation-group")
        .call(makeAnnotations)
}

function barplot(input) {

    let data = reshape(input)

    plot(data)
    annotate1()

    d3.select("#answer").on("click", (e,d) => {
        // Change label to answer 2
        let button = document.getElementById("answer")
        let answer1 = button.innerHTML === "Answer 1"
        button.innerHTML = answer1 ? "Answer 2" : "Answer 1"

        // Make plot
        if (! answer1) {
            // Update to answer 1
            data.sort((a,b) => d3.ascending(a.elf_id, b.elf_id))
            plot(data)
            annotate1()
        } else {
            // Update to answer 2
            data.sort((a,b) => d3.ascending(a.elf_calories, b.elf_calories))
            plot(data)
            annotate2()

        }

    })

}

barplot(elves)

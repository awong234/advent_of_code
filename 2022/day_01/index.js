import { text } from "https://cdn.skypack.dev/d3-fetch@3";

// Analyze dataset -- Part I

const readme = 'readme.md'

fetch(readme)
    .then(response => response.text())
    .then(txt => {
        let part1 = txt.split("# Part Two")[0]
        document.getElementById('problem1').innerHTML = marked.parse(part1)
    })


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
console.log(`Max value is ${maxval}`)
console.log(`Elf with max value is ${maxid}`)

var div_input_data = document.getElementById("input-data-1")
div_input_data.appendChild(document.createElement('pre')).append(datalines.join("\n"))

var answer_div = document.getElementById("output-1")
answer_div.appendChild(document.createElement('pre')).append(maxval + "\n" + maxid)

// Analyze -- Part II

fetch(readme)
    .then(response => response.text())
    .then(txt => {
        let part1 = "# Part Two" + txt.split("# Part Two")[1]
        document.getElementById('problem2').innerHTML = marked.parse(part1)
    })

var sum

function analyze_2 () {
    // Order elves by calories
    let order = Array.from(Array(elves.elf_calories.length).keys())
        .sort((a, b) => elves.elf_calories[a] > elves.elf_calories[b] ? -1 : (elves.elf_calories[b] > elves.elf_calories[a]) | 0)

    sum = elves.elf_calories[order[0]] + elves.elf_calories[order[1]] + elves.elf_calories[order[2]]
    console.log(order)
    console.log(elves.elf_calories[order[0]])
    console.log(elves.elf_calories[order[1]])
    console.log(elves.elf_calories[order[2]])
    console.log(sum)

}

analyze_2()


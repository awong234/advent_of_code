// Improve code structure a little bit by using a common.js file
import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()

var datalines = await input_data()
record_input_data(datalines)

// Begin analysis

var dataset = datalines.split('\n')
dataset.pop() // Removes last element, which is an empty string
console.log(dataset)

function generateAlphabet(capital = false) {
    return [...Array(26)].map((_, i) => String.fromCharCode(i + (capital ? 65 : 97)))
}

// Prep the letter priorities
const lower_case = generateAlphabet(false)
const upper_case = generateAlphabet(true)

const lower_case_values = {}
const upper_case_values = {}
lower_case.forEach((e, i) => {
    lower_case_values[e] = i + 1
})
upper_case.forEach((e, i) => {
    upper_case_values[e] = i + 27
})

const scores = { ...lower_case_values, ...upper_case_values }

function halve(text) {
    var l = text.length
    var halfpt = l / 2
    return [text.slice(0, halfpt).split(''), text.slice(halfpt).split('')]
}

function find_common(parts) {
    var common = parts[0]
        // Set operation for intersection
        .filter(value => parts[1].includes(value))

    return [...new Set(common)] // Distinct value only
}

function analyze1 (data) {
    // Split the text in half, then find the item that is in both compartments
    // Iterate over the list
    var total_score = 0;
    for (let line of data) {
        var parts = halve(line);
        var common_letters = find_common(parts);
        total_score += scores[common_letters];
    };
    // console.log(total_score);
    return total_score;
}

var answ1 = analyze1(dataset);

// Write answer
var output1 = document.getElementById('output-1');
output1.appendChild(document.createElement('pre')).append(`Total score is: ${answ1}`);

function dyn1 (data) {
    var subdata = data.slice(0, 3);
    var ans = analyze1(subdata);
    var div_dyn1 = document.getElementById('dynamic-1');
    var textarea = document.getElementById('dyn1-textarea');
    var ansdiv = document.getElementById('dyn1-ansarea');

    subdata.map(v => {
        console.log(v)
        var l = v.length
        var halfpt = l / 2
        let halves = halve(v)
        let common = find_common(halves)
        let fulltext = v.split('')
        let textarea_p = document.getElementById('dyn1-textarea').appendChild(document.createElement('p'))
        for (let i in fulltext) {
            if (fulltext[i] == common) {
                console.log('creating new span')
                // Create new p object
                var special_char = textarea_p.appendChild(document.createElement('span'))
                special_char.setAttribute('class', 'red-text')
                special_char.append(fulltext[i])
            } else {
                console.log('appending to p')
                textarea_p.append(fulltext[i])
            }
        }
    });
};

dyn1(dataset);


function find_common_2 (a, b) {
    return new Set(Array.from(a).filter(v => b.has(v)));
};

function analyze2 (data) {
    // Collect each groups' letters altogether.
    var total_score = 0;
    var group = 1;
    for (let line=0; line<data.length; line+3) {
        let data_group = data.slice(line, line+3);
        let data_group_set = data_group.map(v => new Set(v));
        let common = data_group_set.reduce(find_common_2);
        total_score += scores[Array.from(common)[0]];
        // console.log(`group is ${group}`);
        // console.log(`line is ${line}`);
        // console.log(data_group);
        // console.log(`common letter is ${Array.from(common)[0]}`);
        // console.log(total_score);
        line+=3;
        group++;
    };
    // console.log(total_score);
    return(total_score);
};

var answ2 = analyze2(dataset)
var output2 = document.getElementById('output-2')
output2.appendChild(document.createElement('pre')).append(`Total score is: ${answ2}`)

// Charts

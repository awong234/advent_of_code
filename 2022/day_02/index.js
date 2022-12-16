// Improve code structure a little bit by using a common.js file
import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()
record_input_data()

/*
Learnings this day:
- How to reverse an object, keys for values
- Continuing to understand object scope
- Use of await sleep to alter HTML on increments
- More practice with `then` and callbacks
*/


// Begin analysis
var data = input_data()

const op_decode = {
    "A": "rock",
    "B": "paper",
    "C": "scissors"
}

const my_decode = {
    "X": "rock",
    "Y": "paper",
    "Z": "scissors"
}

const win_condition = {
    "rock": "scissors",
    "paper": "rock",
    "scissors": "paper"
}

// Flip the values around for the lose condition
var lose_condition = {}

for (let key in win_condition) {
    lose_condition[win_condition[key]] = key
}

const shape_scores = {
    "rock": 1,
    "paper": 2,
    "scissors": 3
}

const win_scores = {
    "win": 6,
    "draw": 3,
    "lose": 0
}

function analyze_1(data) {
    var score = 0
    var a1 = document.getElementById('output-1')
    var td_round = document.getElementById('d1-table-round')
    var td_me = document.getElementById('d1-table-my-shape')
    var td_op = document.getElementById('d1-table-op-shape')
    var td_outcome = document.getElementById('d1-table-outcome')
    var td_score = document.getElementById('d1-table-score')

    async function calc(data) {
        let internal_score = 0
        for (let i = 0; i < data.length; i++) {
            if (data[i].length === 0) {
                return
            }
            var outcome, color
            let op_code = data[i][0]
            let my_code = data[i][2]
            let op_shape = op_decode[op_code]
            let my_shape = my_decode[my_code]
            let outcome_against = win_condition[my_shape]
            if (op_shape === my_shape) {
                outcome = 'draw'
                color = "gray"
            } else if (outcome_against === op_shape) {
                outcome = 'win'
                color = "green"
            } else {
                outcome = 'lose'
                color = "red"
            }
            internal_score += win_scores[outcome]
            internal_score += shape_scores[my_shape]
            td_round.innerHTML = i
            td_me.innerHTML = my_shape
            td_op.innerHTML = op_shape
            td_outcome.innerHTML = outcome
            td_outcome.setAttribute('bgcolor', color)
            td_score.innerHTML = internal_score
            await sleep(0)
        }
    }

    function sleep(ms) {
        return new Promise(resolveFunc => setTimeout(resolveFunc, ms));
    }

    calc(data)

    // Calculate the final answer separately ;; much faster without the await sleep(0), and is not blocked by calc()
    for (let i = 0; i < data.length; i++) {
        if (data[i].length === 0) {
            break
        }
        var outcome
        let op_code = data[i][0]
        let my_code = data[i][2]
        let op_shape = op_decode[op_code]
        let my_shape = my_decode[my_code]
        let outcome_against = win_condition[my_shape]
        if (op_shape === my_shape) {
            outcome = 'draw'
        } else if (outcome_against === op_shape) {
            outcome = 'win'
        } else {
            outcome = 'lose'
        }
        score += win_scores[outcome]
        score += shape_scores[my_shape]
    }

    var output_statement = `Final Score: ${score}`
    a1.appendChild(document.createElement("pre")).append(output_statement)
}

function analyze_2(data) {
    var score = 0
    const decode2 = {
        "X": "lose",
        "Y": "draw",
        "Z": "win"
    }
    let a2 = document.getElementById("output-2")
    var td_round = document.getElementById('d2-table-round')
    var td_me = document.getElementById('d2-table-my-shape')
    var td_op = document.getElementById('d2-table-op-shape')
    var td_outcome = document.getElementById('d2-table-outcome')
    var td_score = document.getElementById('d2-table-score')

    async function calc(data) {
        function sleep(ms) {
            return new Promise(resolveFunc => setTimeout(resolveFunc, ms));
        }
        let internal_score = 0
        for (let i = 0; i < data.length; i++) {
            if (data[i].length === 0) {
                break
            }
            let op_code = data[i][0]
            let my_code = data[i][2]
            let op_shape = op_decode[op_code]
            let outcome = decode2[my_code]
            // Knowing outcome tells us what our shape should be.
            let my_shape, color
            if (outcome === 'draw') {
                my_shape = op_shape
                color = "gray"
            } else if (outcome === 'win') {
                my_shape = lose_condition[op_shape]
                color = "green"
            } else { // Lose
                my_shape = win_condition[op_shape]
                color = "red"
            }
            internal_score += win_scores[outcome]
            internal_score += shape_scores[my_shape]
            td_round.innerHTML = i
            td_me.innerHTML = my_shape
            td_op.innerHTML = op_shape
            td_outcome.innerHTML = outcome
            td_outcome.setAttribute('bgcolor', color)
            td_score.innerHTML = internal_score
            await sleep(0)
        }
    }

    calc(data)

    for (let i = 0; i < data.length; i++) {
        if (data[i].length === 0) {
            break
        }
        let op_code = data[i][0]
        let my_code = data[i][2]
        let op_shape = op_decode[op_code]
        let outcome = decode2[my_code]
        // Knowing outcome tells us what our shape should be.
        let my_shape
        if (outcome === 'draw') {
            my_shape = op_shape
        } else if (outcome === 'win') {
            my_shape = lose_condition[op_shape]
        } else { // Lose
            my_shape = win_condition[op_shape]
        }
        score += win_scores[outcome]
        score += shape_scores[my_shape]
    }

    var output_statement = `Final Score: ${score}`
    a2.appendChild(document.createElement("pre")).append(output_statement)
}

data.then(d => {
    var datalines
    datalines = d.split("\n")
    analyze_1(datalines)
    analyze_2(datalines)
})



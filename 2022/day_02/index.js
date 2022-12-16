// Improve code structure a little bit by using a common.js file
import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()
record_input_data()

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

function analyze_1 (data) {
    var score = 0
    var a1 = document.getElementById('output-1')
    var td_round = document.getElementById('d1-table-round')
    var td_me    = document.getElementById('d1-table-my-shape')
    var td_op    = document.getElementById('d1-table-op-shape')
    var td_score = document.getElementById('d1-table-score')

    async function calc (data) {
        for (let i=0; i < data.length; i++) {
            if (data[i].length === 0) {
                return
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
            td_round.innerHTML = i
            td_me.innerHTML = my_shape
            td_op.innerHTML = op_shape
            td_score.innerHTML = score
            // console.log(`Round: ${i}`)
            // console.log(`Opponent played ${op_shape} (code ${op_code})`)
            // console.log(`I played ${my_shape} (code ${my_code})`)
            // console.log(`I ${outcome}`)
            // console.log(`Score: ${score}`)
            await sleep(0)
        }
    }

    function sleep(ms) {
        return new Promise(resolveFunc => setTimeout(resolveFunc, ms));
    }

    calc(data).then(function() {
        // Write data to HTML
        var output_statement = `Final Score: ${score}`
        a1.appendChild(document.createElement("pre")).append(output_statement)
    })
}



data.then(d => {
    var datalines
    datalines = d.split("\n")
    analyze_1(datalines)
})



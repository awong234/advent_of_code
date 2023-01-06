import { text } from "https://cdn.skypack.dev/d3-fetch@3";

export function parse_readme () {
    let readme = 'readme.md'

    function readme_split(part) {
        fetch(readme)
            .then(response => response.text())
            .then(text => {
                let part_txt = text.split("# Part II")[part - 1]
                if (typeof part_txt === 'undefined') {
                    return
                }
                let prepend_txt = "# Part II"
                part_txt = part == 1 ? part_txt : prepend_txt + part_txt
                let html_insert = marked.parse(part_txt)
                document.getElementById("problem" + part).innerHTML = html_insert
            })
    }

    readme_split(1)
    readme_split(2)
}

export async function input_data () {
    const input = "input.txt";
    var datalines = text(input)
    return datalines
}

export function record_input_data (d) {
    let div_input_data = document.getElementById("input-data-1")
    div_input_data.appendChild(document.createElement('pre')).append(d)
}

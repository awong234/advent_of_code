import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()
var datalines = await input_data()
record_input_data(datalines)
console.log(datalines.split("\n"))

function build_filesystem (data) {
    // Build the file system
    let folders = {
        "\/": {
            descendents: [],
            parent: null,
            files: []
        }
    }
    let current_folder = ""
    let parent_folder = ""
    let level = 0
    for (let i = 0; i < data.length; i++) {
        let line = data[i].split(" ")
        let is_command = line[0] === "$"
        if (is_command) {
            // Handle commands
            if (line[1] === "cd") {
                if (line[2] === "..") {
                    // Moving up a directory. Decrement level.
                    // console.log("going up ... line " + (i + 1))
                    current_folder = folders[current_folder].parent
                    level--
                    // console.log("current folder is " + current_folder + " level " + level + " line " + (i + 1))
                }
                else {
                    // This is movement into a new directory. Increment level.
                    parent_folder = current_folder
                    if (line[2] === "/") {
                        current_folder = line[2]
                    } else if (parent_folder === "/") {
                        current_folder = parent_folder + line[2]
                    } else {
                        current_folder = parent_folder + "/" + line[2]
                    }
                    level++

                    // console.log(line)
                    // console.log("current folder is " + current_folder + " level " + level + " line " + (i + 1))
                    folders[current_folder] = {
                        descendents: [],
                        parent: parent_folder,
                        files: []
                    }
                }
            }
        } else {
            // Handle ls output
            if (Number.isInteger(parseInt(line[0]))) {
                // This is a file
                let file_name = line[1]
                let file_size = line[0]
                folders[current_folder].files.push({ name: file_name, size: parseInt(file_size) })
            } else {
                // This is another directory
                let dir_name = line[1]
                if (parent_folder === "") {
                    folders[current_folder].descendents.push(current_folder + dir_name)
                } else {
                    folders[current_folder].descendents.push(current_folder + "/" + dir_name)
                }

            }
        }
    }
    return (folders)
}

function add(acc, a) {
    return acc + a
}

function sum_file_sizes(folder, fs) {
    let file_sizes = fs[folder].files.map(d => d.size).reduce(add, 0)
    // console.log(`Folder ${folder} has size ${file_sizes}`)
    let descendents = fs[folder].descendents
    if (descendents.length > 0) {
        for (let d of descendents) {
            // console.log(`Entering folder ${d}`)
            let desc_file_size = sum_file_sizes(d, fs)
            file_sizes += desc_file_size
        }
    }
    // console.log(`Folder ${folder} has size ${file_sizes} after adding desc`)
    return (file_sizes)
}

// First problem
function analyze1 (data) {
    data = data.split("\n")
    data.pop() // Remove blank entry at end
    let fs = build_filesystem(data)
    console.log(fs)
    let all_folders = Object.keys(fs)
    let file_sizes = all_folders.map(f => sum_file_sizes(f, fs))
    console.log(file_sizes)
    console.log(file_sizes.filter(f => f <= 100000))
    return (file_sizes.filter(f => f <= 100000)).reduce(add, 0)
}

let ans1 = analyze1(datalines)
let ans1box = document.getElementById('output-1')
ans1box.appendChild(document.createElement("pre")).append(ans1.toLocaleString("en-US"))

function analyze2 (data) {
    data = data.split("\n")
    data.pop() // Remove blank entry at end
    let fs = build_filesystem(data)
    let all_folders = Object.keys(fs)
    let file_sizes = all_folders.map(f => sum_file_sizes(f, fs))
    const total_space = 70000000
    const space_needed = 30000000
    let free_space = total_space - file_sizes[0]
    let min_space = space_needed - free_space
    console.log(`Free space: ${free_space}`)
    console.log(`Minimum space to clear: ${min_space}`)
    let candidates = file_sizes.filter(d => d >= min_space)
    console.log(candidates)
    console.log(Math.min(...candidates))
    return(Math.min(...candidates))
}

let ans2 = analyze2(datalines)
let ans2box = document.getElementById('output-2')
ans2box.appendChild(document.createElement("pre")).append(ans2.toLocaleString("en-US"))

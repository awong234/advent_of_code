import { parse_readme, input_data, record_input_data } from "../common.js"

parse_readme()
var datalines = await input_data()
record_input_data(datalines)
console.log(datalines.split("\n"))

function build_filesystem (data) {
    // Build the file system
    let folders = {}
    let current_folder, parent_folder, level
    for (let i = 0; i < data.length; i++) {
        let line = data[i]
        let is_command = line[0] === "$"
        if (is_command) {
            // Handle commands
            if (line === "$ cd /") {
                // First command, set up structure
                folders["\/0"] = {
                    descendents: [],
                    parent: null,
                    files: []
                }
                current_folder = "\/"
                level = 0
                console.log("current folder is " + current_folder + " level " + level + " line " + (i+1))
            }
            else if (line === "$ cd ..") {
                // Moving up a directory. Decrement level.
                console.log("going up ... line " + (i+1))
                current_folder = folders[current_folder+level].parent
                level--
                console.log("current folder is " + current_folder + " level " + level + " line " + (i+1))
            }
            else if (line != "$ ls") {
                // This is movement into a new directory. Increment level.
                level++
                parent_folder = current_folder
                current_folder = line.split(" ")[2]
                console.log(line)
                console.log("current folder is " + current_folder + " level " + level + " line " + (i+1))
                folders[current_folder+level] = {
                    descendents: [],
                    parent: parent_folder,
                    files: []
                }
            }
        } else {
            // Handle ls output
            if (Number.isInteger(parseInt(line.split(" ")[0]))) {
                // This is a file
                let file_name = line.split(" ")[1]
                let file_size = line.split(" ")[0]
                folders[current_folder+level].files.push({ name: file_name, size: parseInt(file_size) })
            } else {
                // This is another directory
                let dir_name = line.split(" ")[1]
                folders[current_folder+level].descendents.push(dir_name+(level+1))
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
    console.log(`Folder ${folder} has size ${file_sizes}`)
    let descendents = fs[folder].descendents
    if (descendents.length > 0) {
        for (let d of descendents) {
            console.log(`Entering folder ${d}`)
            let desc_file_size = sum_file_sizes(d, fs)
            file_sizes += desc_file_size
        }
    }
    console.log(`Folder ${folder} has size ${file_sizes} after adding desc`)
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

console.log(analyze1(datalines))

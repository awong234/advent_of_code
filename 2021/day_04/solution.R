file = 'input_pgr.txt'

samples = readLines(file, n = 1)
samples = as.integer(strsplit(samples, split = ',')[[1]])

cat(file = 'awk.awk',
'
BEGIN {
    i=1
    OFS=","
    $1=$1
    print "index", "v1", "v2", "v3", "v4", "v5"
}
{
    if (NR > 2) {
        if ($1 == "") {
            i+=1
            next
        }
        print i, $1, $2, $3, $4, $5
    }
}
'
)

tables = data.table::fread(cmd = sprintf('awk -f awk.awk %s', file))
unlink('awk.awk')
tables_split = split(tables, f = tables$index, drop = TRUE)
tables_split = lapply(tables_split, function(x) x[,-'index'])
tables_index = replicate(n = length(tables_split), expr = matrix(rep(FALSE, 25), nrow = 5, ncol = 5), simplify = FALSE)

run = function() {
    for (s in seq_along(samples)) {
        print(samples[s])
        tables_index = Map(x = tables_split, y = tables_index, function(x,y) {
            samples[s] == x | y
        })
        if (s < 5) {
            next
        }
        for (t in seq_along(tables_index)) {
            # Check winning condition
            cat("Checking table ", t, '\n')
            table = tables_index[[t]]
            trus = which(table, arr.ind = TRUE)
            a = any(rle(sort(trus[,'col']))[['lengths']] == 5)
            b = any(rle(sort(trus[,'row']))[['lengths']] == 5)
            if (b|a) {
                message("Winner is: ", t)
                return(list(
                    winner = t,
                    table = table,
                    winnum = samples[s]
                ))
            }
        }
    }
}

win = run()
sum(as.matrix(tables_split[[win$winner]] * ! win$table)) * win$winnum

# Part 2
revsamp = rev(samples)
tables_index = tables_index = replicate(n = length(tables_split), expr = matrix(rep(TRUE, 25), nrow = 5, ncol = 5), simplify = FALSE)

run = function(samples, tables_index, tables_split) {
    for (s in seq_along(samples)) {
        message(s, ", ", samples[s])
        tables_index = Map(x = tables_split, y = tables_index, function(x,y) {
            samples[s] != x & y
        })
        # if (s < 5) {
        #     next
        # }
        for (t in seq_along(tables_index)) {
            # Check winning condition
            cat("Checking table ", t, '\n')
            table = tables_index[[t]]
            print(table)
            trus = which(table, arr.ind = TRUE)
            a = any(rle(sort(trus[,'col']))[['lengths']] == 5)
            b = any(rle(sort(trus[,'row']))[['lengths']] == 5)
            if (!b & !a) {
                message("last to finish is: ", t)
                val_table = tables_split[[t]]
                # Put the winning slot back
                table = samples[s] == val_table | table
                return(list(
                    winner = t,
                    table = table,
                    winnum = samples[s]
                ))
            }
        }
    }
}
win = run(samples = revsamp,
    tables_index = tables_index,
    tables_split = tables_split)

sum(as.matrix(tables_split[[win$winner]] * !win$table)) * win$winnum

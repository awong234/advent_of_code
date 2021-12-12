checkpoint::checkpoint(config::get('checkpoint_date'))
file = 'input_pgr.txt'
first = readLines(file, n = 1)
mat = as.matrix(read.fwf(file = file, widths = rep(1, nchar(first))))

# Get neighbors, save as lookup.
neighbors = function(ind) {
    stopifnot(nrow(ind) == 1 & ncol(ind) == 2 | length(ind == 2))
    if (!is.matrix(ind)) ind = matrix(ind, nrow = 1)
    newmat = cbind(rep(ind[1], 8), rep(ind[2], 8))
    addmat = matrix(c(
        0,  1,
        0, -1,
        1,  0,
        -1,  0,
        1,  1,
        -1, -1,
        1, -1,
        -1,  1
    ), byrow = TRUE, nrow = 8)
    ns = newmat + addmat
    ns = ns[ns[,1] != 0 & ns[,1] <= 10 & ns[,2] != 0 & ns[,2] <= 10, ]
    return(ns)
}

to_cell = function(ind) {
    (10 * (ind[,1]-1)) + ind[,2]
}

promote = function(vec, at = 1:100, depth = 0, verbose = FALSE) {
    all_flashers = c()
    .promote = function(vec, at = at, depth = depth) {
        if (verbose) message("DEPTH = ", depth)
        if (verbose) cat("Promoting ", paste0(at, collapse = ','), '\n')
        newvec = vec
        newvec[at] = vec[at] + 1
        flashers = which(newvec > 9)
        all_flashers <<- unique(c(all_flashers, flashers))
        newvec[flashers] = 0
        if (verbose) {
            cat(length(flashers), " flashers\n")
            cat("all flashers: ", paste0(all_flashers, collapse = ','), '\n')
        }
        if (length(flashers)) {
            flasher_neighbors = ns[flashers]
            for (i in seq_along(flashers)) {
                to_promote = setdiff(flasher_neighbors[[i]], all_flashers) # Promote everyone except those who flashed already.
                newvec = .promote(newvec, at = to_promote, depth = depth + 1)
            }
        }
        newvec
    }
    newvec = .promote(vec, at, depth)
    return(
        list(
            nflashes = length(all_flashers),
            cells = newvec
        )
    )
}

rowadd = 0
ns = list()
for (i in 1:ncol(mat)) {
    for (j in 1:ncol(mat)) {
        cell = rowadd + j
        ns[[cell]] = to_cell(neighbors(c(i,j)))
    }
    rowadd = rowadd + 10
}

part1 = function() {
    vec = as.integer(mat)
    nflashers = 0
    for (i in 1:100) {
        res = promote(vec)
        vec = res$cells
        nflashers = nflashers + res$nflashes
    }

    matrix(vec, nrow = 10)
    return(nflashers)
}

cat("Part I  solution is:\t", part1(), "\n")


# SEcond part

part2 = function() {
    vec = as.integer(mat)
    nflashers = 0
    first_step = 0
    i = 1
    while (first_step == 0) {
        res = promote(vec)
        vec = res$cells
        nflashers = nflashers + res$nflashes
        if (all(vec == 0)) {
            first_step = i
            break
        }
        i = i + 1
    }

    return(first_step)
}

cat("Part II solution is:\t", part2(), "\n")

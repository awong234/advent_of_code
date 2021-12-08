checkpoint::checkpoint(config::get("checkpoint_date"))
dir = here::here('2021', 'day_03')
mat = as.matrix(read.fwf(file.path(dir, 'input.txt'), widths = rep(1, 12)))
ncols = ncol(mat)
nrows = nrow(mat)

convert_bits = function(x) {
    pad = c(rep(as.raw(0L), times = 32 - length(x)))
    bits = rev(c(pad, x))
    packBits(bits, 'integer')
}

tally_fn = function(x) {
    ones = matrix(rep(1, nrow(x)), byrow = TRUE, nrow = 1)
    ones %*% x
}

# Part 1
tally = tally_fn(mat)
gamma = tally > (nrows / 2)
gamma_int = convert_bits(gamma)
epsilon = !gamma
eps_int = convert_bits(epsilon)

prod = gamma_int * eps_int
sprintf("Product is: %d", prod)

# Part 2
rating = function(mat, type = c('o2', 'co2')) {
    if (type == 'o2') {
        `%o%` = `<`
    } else {
        `%o%` = `>=`
    }
    ncols = ncol(mat)
    for (i in 1:ncol(mat)) {
        nrows = nrow(mat)
        if (nrows == 1L) break
        tally = tally_fn(mat)
        which_keep = as.integer(tally[i] %o% (nrows / 2))
        mat = mat[mat[,i] == which_keep, , drop = FALSE]
    }
    return(mat)
}
# rating(mat, type = 'o2')
# rating(mat, type = 'co2')
o2_val = convert_bits(rating(mat, type = 'o2'))
co2_val = convert_bits(rating(mat, type = 'co2'))
sprintf("Combined rating is: %d", o2_val * co2_val)

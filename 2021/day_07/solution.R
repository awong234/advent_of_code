file = 'input.txt'
data = matrix(as.integer(strsplit(x = readLines(file), split = ',')[[1]]), ncol = 1)

# mean(data)    # Answer to part II suspiciously close to mean, could probably just compute mean and round here.
# median(data)  # Answer to part I  suspiciously close to median, could probably just compute median here.

# Part I
all = seq(range(data)[1], range(data)[2])
diffs = outer(X = data, Y = all, FUN = function(x,y) abs(x-y))
diffs = drop(diffs)
sprintf("Fuel spent in Part I: %d", colSums(diffs)[which.min(colSums(diffs))])
# all[which.min(colSums(diffs))]
# Part II
termial = function(x) {
    vapply(x, function(x) sum(seq(x, 0)), FUN.VALUE = c(0L))
}

termial_lookup = cbind(all, termial(all))
diffs = outer(X = data, Y = all, FUN = function(x,y) abs(x-y))
diffs = drop(diffs)
diffs[] = termial_lookup[match(x = diffs, table = termial_lookup[,1]) ,2]
sprintf("Fuel spent in Part II: %d", colSums(diffs)[which.min(colSums(diffs))])
# all[which.min(colSums(diffs))]

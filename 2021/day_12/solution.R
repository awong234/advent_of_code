file = 'input_pgr.txt'
paths = data.table::fread(cmd = sprintf('awk \'BEGIN{FS="-";OFS=","} {$1=$1;print $0}\' %s', file), header = FALSE)
names(paths) = c('from', 'to')
paths_rev = paths
names(paths_rev) = c("to", "from")
paths = rbind(paths, paths_rev)

is_lower = function(x) {
    x == tolower(x) & (! x %in% c("start", "end"))
}
is_upper = function(x) {
    x == toupper(x) & (! x %in% c("start", "end"))
}

path_points = function(paths) {
    adj = table(paths$from, paths$to)
    # Pass through big caves as much as you want
    bigcaves = adj[ , is_upper(colnames(adj)) ]
    adj[ , is_upper(colnames(adj))][bigcaves != 0] = Inf
    # Cannot return to start
    adj[, colnames(adj) == 'start'] = 0L
    # Cannot move from end anywhere else
    adj[rownames(adj) == 'end',] = 0L
    # small caves adjacent to each other get 0 visitation points
    # adj[ which(is_lower(rownames(adj))), which(is_lower(colnames(adj)))] = 0
    adj
}

adj = path_points(paths)
visit = function(mat, from, depth = 0) {
    dest_options = mat[rownames(mat) == from, ]
    dest_options = names(dest_options)[ dest_options > 0 ]
    dest_ind = which(dest_options > 0)
    if (length(dest_options) == 0) {
        if (from == 'end') {
            return(1)
        } else {
            return(NULL)
        }
    }
    # Recursively apply visit, decrementing from visit counter within each cave path
    out = lapply(dest_options, function(to) {
        # Wherever we go next, we remove 1 from the visit ticker. Except for big
        # caves, those have infinite visits. Because the matrix is passed on to
        # subsequent visits, the tickers are all independent.
        mat[, colnames(mat) == to] = mat[, colnames(mat) == to] - 1
        visit(mat, to, depth = depth + 1)
    })
    return(out)
}
opts = visit(adj, 'start')
cat("First solution is: ", sum(unlist(opts)), "\n")

# Part II

visit2 = function(mat, from, depth = 0) {
    small_caves = colnames(mat)[is_lower(colnames(mat))]
    small_cave_visited = rep(0, length(small_caves))
    names(small_cave_visited) = small_caves
    .visit = function(mat, from, depth = 0, small_cave_visited) {
        dest_options = mat[rownames(mat) == from, ]
        dest_options = names(dest_options)[ dest_options > 0 ]
        dest_ind = which(dest_options > 0)
        if (length(dest_options) == 0) {
            if (from == 'end') {
                return(1)
            } else {
                return(NULL)
            }
        }
        out = lapply(dest_options, function(to) {
            if (is_lower(to)){
                # On visit, add back the index
                small_cave_visited[small_caves == to] = small_cave_visited[small_caves == to] + 1
                if (any(small_cave_visited > 1)) {
                    # If any small cave visited twice, indicate which cave was exceeded.
                    exceeded = names(small_cave_visited)[small_cave_visited > 0]
                    # can't visit that cave any more
                    mat[, colnames(mat) %in% exceeded] = 0
                    mat[, colnames(mat) == to] = mat[, colnames(mat) == to] - 1
                }
            } else {
                mat[, colnames(mat) == to] = mat[, colnames(mat) == to] - 1
            }
            # from_collect = c(from, to)
            .visit(mat, to, depth = depth + 1, small_cave_visited)
        })
        return(out)
    }
    .visit(mat, from, depth, small_cave_visited)
}

opts = visit2(adj, 'start')
cat("Second solution is", sum(unlist(opts)), "\n")


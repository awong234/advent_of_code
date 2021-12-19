checkpoint::checkpoint(config::get('checkpoint_date'))

library(furrr)

# future::plan('multisession')

file = 'input_pgr.txt'
w = nchar(readLines(file, n = 1))
mat = as.matrix(read.fwf(file = file, widths = rep(1, w)))

dim = dim(mat)

get_neighbors = function(pt, mat, probs = NULL, dir_wt) {
    dim = dim(mat)
    pt = unname(pt)
    down = pt + c(1,0)
    up = pt + c(-1,0)
    right = pt + c(0,1)
    left = pt + c(0,-1)
    nbr = rbind(up, down, left, right)
    keep = nbr[,1] > 0 & nbr[,1] <= dim[1] & # Within X bounds
        nbr[,2] > 0 & nbr[,2] <= dim[2]   # Within Y bounds
    nbr = nbr[keep, , drop = FALSE]
    vals = mat[nbr]
    nbr = cbind(nbr, vals)
    colnames(nbr) = c('x', 'y', 'z')
    if (is.null(probs)) {
        # Select based on the z value -- but weight down and right heavier
        probs = nbr[, 'z']
        probs = (max(probs) + 1) - probs
        probs = probs * dir_wt[keep]
        nbr = cbind(nbr, probs)
        # If at the margin, don't allow it to move away from the goal
        if (pt[1] == dim[1]) {
            # At the bottom; don't move left
            probs = probs * c(1, 1, 0, 1)[keep]
        }
        if (pt[2] == dim[2]) {
            # At the right; don't move down
            probs = probs * c(1, 0, 1, 1)[keep]
        }

    } else {
        probs = probs[keep]
        nbr = cbind(nbr, probs)
    }

    colnames(nbr) = c('x', 'y', 'z', 'p')

    return(nbr)
}

hash = function(x) {
    UseMethod('hash', x)
}

# bench::mark(
#     digest::sha1(x = c(1,1)),
#     digest::digest(c(1,1), algo = "crc32"),
#     digest::digest(c(1,1), algo = "spookyhash"),
#     digest::digest(c(1,1), algo = "xxhash32"),
#     paste0(c(1,1), collapse = ''),
#     stringr::str_c(c(1,1), collapse = ''),
#     stringi::stri_c(c(1,1), collapse = ""),
#     check = FALSE
# )

hash.default = function(x) {
    # digest::digest(x, algo = 'sha1')
    paste0(x, collapse = '')
}

hash.matrix = function(x) {
    hashes = vector('character', nrow(x))
    for (i in 1:nrow(x)) {
        hashes[i] = hash.default(x[i, ])
    }
    return(hashes)
}

# -----------

set.seed(1)

make_path = function(mat, plot = FALSE, exag_factor = 1, plot_delay = 0.1, direction_weights = c(1,1,1,1)) {
    plot_path = function(x) {
        plot.new()
        plot.window(xlim = c(1,dim[1]), ylim = c(1,dim[2]))
        lines(x)
        points(x)
        points(current, col="red")
        axis(side = 1, at = seq(1, dim[1]), labels = seq(1, dim[1]), tick = TRUE)
        axis(side = 2, at = seq(1, dim[1]), labels = seq(1, dim[1]), tick = TRUE)
    }
    path = matrix(NA, nrow = prod(dim), ncol = 3)
    visited = matrix(numeric(0), nrow = 0, ncol = 3)
    dim = dim(mat)
    current = cbind(matrix(c(1,1), nrow = 1), mat[1,1])
    colnames(path) = colnames(current) = c('x', 'y', 'z')
    path[1, ] = current
    i = 1
    while (TRUE) {
        if (all(current[, c(1,2)] == dim)) {
            break
        }
        # browser()
        nbrs = get_neighbors(current[, c('x', 'y'), drop=FALSE], mat, probs = NULL, dir_wt = direction_weights)
        # Remove visited
        keep = sapply(1:nrow(nbrs), function(x) {
            !any(nbrs[x,1] == visited[,1] & nbrs[x,2] == visited[,2], na.rm = TRUE)
        })
        nbrs = nbrs[keep, , drop=FALSE]
        # Pick next location
        if (nrow(nbrs) == 0) {
            # Backed into a corner, back up
            path[i, ] = c(NA, NA, NA)
            i = i - 1
            current = path[i, , drop=FALSE]
        } else {
            i = i + 1
            probs = nbrs[, 'p'] ^ exag_factor / sum(nbrs[, 'p'] ^ exag_factor)
            current = nbrs[sample(1:nrow(nbrs), size = 1, prob = probs), c('x', 'y', 'z'), drop=FALSE]
            path[i,] = current
            visited = unique(rbind(visited, current))
        }
        if (plot) {
            plot_path(path)
            Sys.sleep(plot_delay)
        }
        # cat(i, '\r')

    }

    path = path[complete.cases(path), ]

    return(path)
}

path = make_path(mat, F, exag_factor = 2, plot_delay = 0.05, direction_weights = c(0, 1, 0, 1))
plot(path, type = 'l')
mtext(sum(path[,'z']), side = 3)

# ----------

N = 5000
sums = rep(NA, N)
paths = list()
minsum = Inf
plotops = par()

par(mfrow = c(1,2))
for (i in 1:N) {
    cat(i, '\r')
    paths[[i]] = make_path(mat, F, exag_factor = 2, direction_weights = c(0, 1, 0, 1))
    sums[i] = sum(paths[[i]][-1,'z'])
    if (sums[i] == min(sums,na.rm=TRUE)) {
        minsum = sums[i]
        plot(paths[[which.min(sums)]], type = 'l')
        mtext(paste0("Iter ", i, " val ", minsum), side = 3)
        plot(x = 1:i, y = Reduce(f = min, x = na.omit(sums), accumulate = TRUE), type = 'l')
    }
}

# --------------

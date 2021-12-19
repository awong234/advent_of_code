checkpoint::checkpoint(config::get('checkpoint_date'))

library(furrr)

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

# -----------

set.seed(1)

make_path = function(mat, plot = FALSE, exag_factor = 1, plot_delay = 0.1, direction_weights = c(1,1,1,1), limit = Inf) {
    hash = function(x) {
        UseMethod('hash', x)
    }

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
    plot_path = function(x) {
        plot.new()
        plot.window(xlim = c(1,dim[1]), ylim = c(1,dim[2]))
        lines(x)
        points(x)
        points(current, col="red")
        axis(side = 1, at = seq(1, dim[1]), labels = seq(1, dim[1]), tick = TRUE)
        axis(side = 2, at = seq(1, dim[1]), labels = seq(1, dim[1]), tick = TRUE)
    }
    dim = dim(mat)
    path = matrix(NA, nrow = prod(dim), ncol = 3)
    visited = matrix(numeric(0), nrow = 0, ncol = 3)
    current = cbind(matrix(c(1,1), nrow = 1), mat[1,1])
    colnames(path) = colnames(current) = c('x', 'y', 'z')
    path[1, ] = current
    pathsum = 0
    hashes = hash(path[1, ])
    i = 1
    cat('\n')
    while (TRUE) {
        cat(pathsum, '\r')
        if (all(current[, c(1,2)] == dim)) {
            break
        }
        if (pathsum > limit) {
            # cat("EARLY END")
            break
        }
        nbrs = get_neighbors(current[, c('x', 'y'), drop=FALSE], mat, probs = NULL, dir_wt = direction_weights)
        nbr_hashes = hash(nbrs[, c('x', 'y', 'z')])
        # Remove visited
        nbrs = nbrs[! nbr_hashes %in% hashes, , drop=FALSE]
        # Pick next location
        if (nrow(nbrs) == 0) {
            # Backed into a corner, back up
            browser()
            path[i, ] = c(NA, NA, NA)
            pathsum = pathsum - current[, 'z']
            i = i - 1
            current = path[i, , drop=FALSE]
            hashes = c(hashes, hash(current))
        } else {
            i = i + 1
            probs = nbrs[, 'p'] ^ exag_factor / sum(nbrs[, 'p'] ^ exag_factor)
            current = nbrs[sample(1:nrow(nbrs), size = 1, prob = probs), c('x', 'y', 'z'), drop=FALSE]
            hashes = c(hashes, hash(current))
            path[i,] = current
            pathsum = pathsum + current[, 'z']
        }
        if (plot) {
            plot_path(path)
            Sys.sleep(plot_delay)
        }
    }

    path = path[complete.cases(path), ]

    return(path)
}

path = make_path(mat, F, exag_factor = 2, plot_delay = 0.05, direction_weights = c(0, 1, 0, 1), limit = Inf)
plot(path, type = 'l')
mtext(sum(path[,'z']), side = 3)

# ----------

simulate = function(N, mat) {
    minsum = Inf
    for (i in 1:N) {
        cat(i, '\n')
        path = make_path(mat, F, exag_factor = 2, direction_weights = c(0, 1, 0, 1), limit = minsum)
        pathsum = sum(path[-1,'z'])
        if (pathsum < minsum) {
            minsum = pathsum
            outpath = path
        }
    }
    return(outpath)
}

sums = rep(NA, N)
minsum = Inf
plotops = par()
par(mfrow = c(1,2))

times = vector(mode = 'numeric', length = 1000)

for (i in 1:1000) {
    # message(i)
    a = Sys.time()
    path = make_path(mat, F, exag_factor = 2, direction_weights = c(0, 1, 0, 1), limit = minsum)
    b = Sys.time()
    times[i] = b-a
    sums[i] = sum(path[-1,'z'])
    if (sums[i] < minsum) {
        minsum = sums[i]
        plot(path, type = 'l')
        mtext(paste0("Iter ", i, " val ", minsum), side = 3)
        plot(x = 1:i, y = Reduce(f = min, x = na.omit(sums), accumulate = TRUE), type = 'l')
    }
}

library(doParallel)
cores = detectCores() - 1
registerDoParallel(cores = cores)
paths = foreach (i = 1:cores) %dopar% {
    sink(file = sprintf("log_%s.txt", i))
    out = simulate(8000, mat)
    sink()
    out
}

min(sapply(paths, function(x) {
    sum(x[-1,'z'])
}))

# ---------

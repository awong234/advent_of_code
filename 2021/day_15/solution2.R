file = 'input_pgr.txt'
w = nchar(readLines(file, n = 1))
mat = as.matrix(read.fwf(file = file, widths = rep(1, w)))

dim = dim(mat)

get_neighbors = function(pt, mat) {
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
    return(nbr)
}

adjacency = function(mat) {
    dim = dim(mat)
    nbrs = vector(mode = 'list', length = dim[1])
    for (i in 1:dim[1]) {
        for (j in 1:dim[2]) {
            nbrs[[i]][[j]] = get_neighbors(c(i,j), mat)
        }
    }
    nbrs
}

adj = adjacency(mat)

search = function(mat) {

}

.search = function(mat, start) {
    adj = adjacency(mat)
    opts = adj[[current[1]]][[current[[2]]]]
    for (op in opts){

    }
}

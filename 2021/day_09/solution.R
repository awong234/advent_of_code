checkpoint::checkpoint(config::get("checkpoint_date"))

REDO_IMAGES = FALSE

file = 'input_pgr.txt'
first = readLines(file, n = 1)
mat = as.matrix(read.fwf(file, widths = rep(1, nchar(first))))

neighbors = function(idx, mat, compress = FALSE, part_two = FALSE) {
    maxrow = nrow(mat)
    maxcol = ncol(mat)
    neighbor_inds = function(ind, part_two = part_two) {
        up = cbind(ind[1] - 1, ind[2])
        down = cbind(ind[1] + 1, ind[2])
        left = cbind(ind[1], ind[2] - 1)
        right = cbind(ind[1], ind[2] + 1)
        out = do.call(rbind, list(
            up, down, left, right
        ))
        out = out[out[,1] > 0 & out[,1] <= maxrow & out[,2] > 0 & out[,2] <= maxcol, ]
        if (part_two) {
            out = out[ mat[out] < 9, , drop = FALSE ]
        }
        return( out )
    }
    neighbors = list()
    for (i in 1:nrow(idx)) {
        neighbors[[i]] = neighbor_inds(idx[i,], part_two)
    }

    if (compress) neighbors = do.call(rbind, neighbors)

    return(neighbors)
}

find_sinks = function(mat) {
    issink = matrix(data = rep(FALSE, length(mat)), nrow = nrow(mat))
    issink[mat == 0] = TRUE
    for (i in 1:8) {
        idx = which(mat == i, arr.ind = TRUE)
        ns = neighbors(idx, mat)
        for (j in 1:nrow(idx)) {
            neighbor_vals = mat[ ns[[j]] ]
            if (all(i < neighbor_vals)) {
                issink[idx[j, , drop = FALSE]] = TRUE
            }
        }
    }
    return(issink)
}

sinks = find_sinks(mat)

sink_idx = which(sinks, arr.ind = TRUE)

cat("Solution to part I  is:\t", sum(mat[sinks] + 1), '\n')


# Part II

basins = mat
basins[] = mat < 9

collect_neighbors = function(idx, mat) {
    sink_neighbors = idx
    nnow = 1
    nlast = -1
    while (nnow != nlast) {
        nlast = nrow(sink_neighbors)
        sink_neighbors = unique(rbind(sink_neighbors, neighbors(sink_neighbors, mat, compress = TRUE, part_two = TRUE)))
        nnow = nrow(sink_neighbors)
    }
    return(sink_neighbors)
}

ns = list()
for (i in 1:nrow(sink_idx)) {
    ns[[i]] = collect_neighbors(sink_idx[i,,drop=FALSE], mat)
}

cat("Solution to part II is:\t", prod(tail(sort(sapply(ns, nrow)), 3)), '\n')

# Picture this!

if (REDO_IMAGES) {
    library(rayshader)
    try(rgl::rgl.close(), silent = TRUE)
    newmat = mat - 8
    newmat %>%
        sphere_shade(texture = 'desert') %>%
        plot_3d(heightmap = newmat,
                        zscale = 1,
                        shadow = TRUE,
                        water = TRUE,
                        watercolor = 'red',
                        solidcolor = 'red',
                        background = '#000a29',
                        baseshape = 'rectangle',
                        zoom = 0.75,
                        phi = 30,
                        theta = 60,
                        windowsize = c(800, 600)
        )

    for (i in 1:nrow(sink_idx)) {
        render_label(heightmap = newmat, text = i, x = sink_idx[i,1], y = sink_idx[i,2],
                     altitude = 15,
                     textsize = 0.7, textcolor = 'mediumspringgreen',
                     alpha = 0.7,
                     linecolor = 'mediumseagreen', linewidth = 1)
    }

    angles = seq(0,360, length.out = 1440)[-1]
    angles = for (i in seq_along(angles)) {
        index = stringr::str_pad(i, width = 4, side = 'left', pad = '0')
        render_camera(theta = -45+angles[i])
        render_snapshot(sprintf('imgs/s%s.png', index))
    }
    system('ffmpeg -framerate 60 -i imgs/s%04d.png -pix_fmt yuv420p animation.mp4 -y')
}

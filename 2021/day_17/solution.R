checkpoint::checkpoint(config::get('checkpoint_date'))

orgpar = par()

# file = 'sample_input.txt'
file = 'input_pgr.txt'
target = readLines(file)
target = strsplit(target, " ")[[1]]
xrange = gsub(pattern = ',', replacement = '', x = target[3])
xrange = gsub(pattern = 'x=', replacement = '', x = xrange)
xrange = gsub(pattern = '\\.\\.', replacement = ':', x = xrange)
xrange = eval(parse(text = xrange))

yrange = target[4]
yrange = gsub(pattern = 'y=', replacement = '', x = yrange)
yrange = gsub(pattern = '\\.\\.', replacement = ':', x = yrange)
yrange = eval(parse(text = yrange))

grid = as.matrix(expand.grid(xrange, yrange))
colnames(grid) = c('x', 'y')

Probe = R6::R6Class(
    public = list(
        velocity = c(NA,NA),
        start = cbind(0,0),
        pos = cbind(0,0),
        distance = NA,
        hit = FALSE,
        beneath = FALSE,
        overshot = FALSE,
        closest = Inf,
        ymax = -Inf,
        target = NULL,
        dots = NULL,
        initialize = function(velocity, target) {
            self$velocity = velocity
            self$target = target
        },
        check_target = function() {
            self$hit = any( self$pos[1] == self$target[,1] & self$pos[2] == self$target[,2] )
        },
        check_beneath = function() {
            self$beneath = all(self$pos[2] < self$target[,2])
        },
        check_overshoot = function() {
            self$overshot = all(self$pos[1] > self$target[,1])
        },
        check_dist = function() {
            dists = fields::rdist(self$pos, self$target)
            dist = dists[which.min(dists)]
            self$distance = dist
        },
        adjust_velocity = function() {
            sx = sign(self$velocity[1])
            self$velocity[1] = self$velocity[1] - (sx * 1)
            self$velocity[2] = self$velocity[2] - 1
        },
        shoot = function() {
            xmov = self$velocity[1]
            ymov = self$velocity[2]
            self$pos = self$pos + c(xmov, ymov)
            self$check_target()
            self$check_beneath()
            self$check_overshoot()
            if (self$pos[2] > self$ymax) {
                self$ymax = self$pos[2]
            }
            self$check_dist()
            if (self$distance < self$closest) {
                self$closest = self$distance
            }
            # Adjust velocity
            self$adjust_velocity()
            # message("Located at:\t", sprintf("%02d %02d", self$pos[1], self$pos[2]))
            # message("Velocity is now\t", sprintf("%02d %02d", self$velocity[1], self$velocity[2]))
            if (self$hit) {
                message("Hit target!")
                message("Y max was\t", self$ymax)
            }
            if (self$beneath) {
                message("Fell below target!")
                # self$closest = Inf
                message("Closest distance was ", self$closest, " units")
            }
            if (self$overshot) {
                message("Overshot the target!")
                message("Closest distance was ", self$closest, " units")
            }
        }
    )
)

shoot = function(xv, yv, target, plot = FALSE, message = FALSE, save = FALSE) {
    probe = Probe$new(velocity = c(xv, yv), target = target)
    if (save | plot) {
        dots = matrix(NA, nrow = 1000, ncol = 2)
        dots[1, ] = c(0,0)
        i = 1
    }
    while (! (probe$hit | probe$beneath | probe$overshot)) {
        if (message) probe$shoot() else suppressMessages(probe$shoot())
        if (save | plot) {
            i = i + 1
            dots[i, ] = probe$pos
        }
    }
    if (plot) {
        xlim = c(min(c(dots[,1], target[,1]), na.rm = TRUE), max(1.1 * target[,1], na.rm = TRUE))
        ylim = c(min(target[,2]) * 1.1, max(dots[,2], na.rm = TRUE))
        plot(grid, xlim = xlim, ylim = ylim, pch = "T", asp = 1)
        points(dots)
        if (i >= 2) {
            lines(dots)
        }
    }
    if (save) {
        probe$dots = dots
    }
    return(probe)
}

shoot(xv = 217, yv = -126, target = grid, plot = TRUE, message = TRUE)

# --------

# Min y is the line where x is the right of the target along a line connecting origin and bottom left.
bottom_left = c(min(grid[,1]), min(grid[,2]))
slope = bottom_left[2] / bottom_left[1]
ymin = floor(slope * max(grid[,1]))

hits = dists = vector()
ys = ymin:200
xs = 21
pos = matrix(nrow = 0, ncol = 2)
par(mfrow = c(1,2))
plot.new()
plot.window(xlim = c(-1, max(grid[,1])*1.1), ylim = c(min(grid[,2]), 0), asp = 1)
axis(1); axis(2)
points(grid, pch = '.')
for (i in seq_along(ys)) {
    y = ys[i]
    prb = shoot(xv = xs, yv = y, target = grid, plot = F, message = F, save = TRUE)
    lines(prb$dots, col = rgb(0, 0, 0, 0.1))
    dists[i] = prb$closest
    hits[i] = prb$hit
}
cols = ifelse(hits, 'red', 'blue')
plot(ys, dists, col = cols)
table(hits)

#
# Notice 21; for some reason there is a break in the hits along y. in any case we know where it ends . . . y=125 . . .
#
# ---------------

best_shots = function(xrange, yrange, dist_tol = 100L) {
    target = as.matrix(expand.grid(xrange, yrange))
    colnames(target) = c('x', 'y')
    max_x = max(xrange)
    # Min x is where the cumulative sum of x reaches the left-most boundary of the target.
    min_x = match(TRUE, cumsum(0:max_x) > min(target[,1])) - 1
    # Min y is the line where x is the right of the target along a line connecting origin and bottom left.
    bottom_left = c(min(target[,1]), min(target[,2]))
    slope = bottom_left[2] / bottom_left[1]
    min_y = slope * max(target[,1])
    valid = matrix(integer(0), nrow = 0, ncol = 3)
    plot.new()
    plot.window(xlim = c(0, max(target[,1])),
                ylim = c(min(target[,2]), 100),
                asp = 1)
    axis(1); axis(2);
    points(target, pch = '.')
    # For a given x, adjust y up, ending when the distance from the target starts increasing past a tolerance
    for (x in min_x:max_x) {
        y = floor(min_y)
        counter = 0
        closest = Inf
        while(TRUE) {
            counter = counter + 1
            cat(sprintf("%04d", counter), sprintf("%04d", x), sprintf("%04d", y), '\r')
            prb = shoot(xv = x, yv = y, target = target, plot = FALSE, message = FALSE, save = TRUE)
            if (prb$overshot) {
                break
            } else if (prb$beneath) {
                # If we're moving farther from the target, stop it; except for
                # the first one, for some reason there is a small spike in
                # distance
                if (x == 21) {
                    if (y > 125) {
                        break
                    } else {
                        closest = prb$closest
                        y = y + 1
                    }
                } else {
                    if (prb$closest > closest) {
                        break
                    } else {
                        closest = prb$closest
                        y = y + 1
                    }
                }
            } else {
                lines(prb$dots, col = rgb(0, 0, 0, 0.1))
                valid = rbind(valid, c(x, y, prb$ymax))
                y = y + 1
            }
        }
    }
    return(valid)
}

dev.off()
plot.new()
valid = best_shots(xrange, yrange)

sprintf("Part I Solution: %s", max(valid[,3]))
sprintf("Part II Solution: %s", nrow(valid))

# -----------

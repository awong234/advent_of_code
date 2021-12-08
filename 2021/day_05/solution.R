checkpoint::checkpoint(config::get("checkpoint_date"))

library(sf)
library(data.table)
# library(ggplot2)

file = 'input.txt'

cat(file = 'lines.awk',
'
BEGIN {
    OFS=", "
    FS=" -> "
}
{
    gsub(/,/, " ")
    $1=$1
    print "LINESTRING(" $0 ")"
}
')

lines = system(sprintf('awk -f lines.awk %s', file), intern = TRUE)
unlink('lines.awk')
lines = sf::st_as_sfc(lines)

# View the lines
# ggplot(lines) +
#     geom_sf()

# Part 1
idx = 1
straights = list()
for (i in 1:length(lines)) {
    if (length(unique(lines[[i]][,2])) == 1 |
        length(unique(lines[[i]][,1])) == 1) {
        straights[[idx]] = lines[[i]]
        idx = idx + 1
    }
}
straights = sf::st_as_sfc(straights)
# ggplot(straights) + geom_sf()

get_points_on_line = function(line) {
    xdiff = abs(diff(line[[1]][,1]))
    ydiff = abs(diff(line[[1]][,2]))
    maxdiff = max(xdiff, ydiff)
    sf::st_line_sample(line, type = 'regular', sample = seq(0, 1, length = maxdiff+1))
}

count_intersects = function(lines) {
    points = list()
    for (i in seq_along(lines)) {
        cat("Iter", i, 'of', length(lines), '\r')
        points[[i]] = get_points_on_line(lines[i])
    }
    cat('\n')
    points = do.call(c, points)
    coords = sf::st_coordinates(points)
    coords[] = as.integer(round(coords,0))
    points = data.table::data.table(coords)
    intersects = points[, .(N=.N), by=c('X', 'Y')]
    res = sum(intersects[,N] >= 2)
    message("There are ", res, " intersections")
    return(res)
}
count_intersects(straights)

# Part 2
count_intersects(lines)


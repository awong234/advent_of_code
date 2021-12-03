# Setup ------------------

checkpoint::checkpoint('2021-11-01')
d1_folder = here::here('src', 'pgr_advent_2021', 'day01')
input = as.integer(readLines(file.path(d1_folder, 'aw_input_01.txt')))

# Part 1 -----------------

diffs = diff(input)
sprintf("Number of values greater than prevoius: %d", sum(diffs > 0))

# Part 2 -----------------

library(data.table)
rolling_sum = frollsum(input, n=3)
rolling_sum_diffs = diff(rolling_sum)
sprintf("Number of rolling values greater than previous: %d", sum(rolling_sum_diffs > 0, na.rm = TRUE))

# Setup ------------------

checkpoint::checkpoint(config::get('checkpoint_date'))
d1_folder = here::here('2021', 'day_01')
input = as.integer(readLines(file.path(d1_folder, 'input.txt')))

# Part 1 -----------------

diffs = diff(input)
sprintf("Number of values greater than prevoius: %d", sum(diffs > 0))

# Part 2 -----------------

library(data.table)
rolling_sum = frollsum(input, n=3)
rolling_sum_diffs = diff(rolling_sum)
sprintf("Number of rolling values greater than previous: %d", sum(rolling_sum_diffs > 0, na.rm = TRUE))

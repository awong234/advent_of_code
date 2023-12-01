dat = readLines('input.txt')
dat_digits = gsub(pattern = "[a-z A-Z]", replacement = "", x = dat, perl = TRUE)
dat_digits_split = strsplit(dat_digits, split = '')
get_first_last = function(x) {
    c(x[1], x[length(x)])
}
numbers = lapply(dat_digits_split, function(x) {
    digits = get_first_last(x)
    numbers = as.integer(paste0(digits, collapse = ''))
})
total = do.call(sum, numbers)

cat("The total is", total, "\n")

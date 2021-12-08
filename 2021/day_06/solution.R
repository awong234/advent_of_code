checkpoint::checkpoint(config::get('checkpoint_date'))

file = 'input.txt'

data = readLines(file)
data = as.integer(strsplit(data, split = ',')[[1]])

Lanternfish = R6::R6Class(
    public = list(
        state = 0L,
        dec_n = 1L,
        children = list(),
        n_children = 0L,
        generation = 1L,
        initialize = function(state, generation) {
            stopifnot(is.integer(state))
            self$state = state
            self$generation = generation
        },
        decrement = function() {
            self$state = self$state - self$dec_n
            if (length(self$children) > 0) {
                lapply(self$children, function(x) {x$decrement(); return(invisible(NULL))})
            }
            if (self$state < 0L) {
                self$state = 6L
                self$children = c(
                    self$children,
                    Lanternfish$new(state = 8L, generation = self$generation + 1L)
                )
                self$n_children = self$n_children + 1L
            }
        }
    )
)

total_children = function(x) {
    if (x$n_children > 0L) {
        childrens_children = sapply(x$children, total_children)
    } else {
        return(x$n_children)
    }
    sum(x$n_children, childrens_children)
}

l = lapply(data, function(x) {
    Lanternfish$new(state = x, generation = 1L)
})

i = 1
while (i <= 80) {
    message("Day ", i)
    lapply(l, function(x) x$decrement())
    i=i+1
}

sum(sapply(l, total_children)) + length(l)

# Part II

# Cannot possibly allocate even a vector for 26,984,457,539 units. Analytically solve.
# 8 age classes
# 0th age class reproduces, and sets itself to age 6
# Classic Leslie matrix operations

data_fac = factor(data, levels = seq(0, 8))
x_init = as.matrix(table(data_fac))

mat = c(
    0, 1, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 1, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 1, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 1, 0, 0,
    1, 0, 0, 0, 0, 0, 0, 1, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 1,
    1, 0, 0, 0, 0, 0, 0, 0, 0
)

P = matrix(mat, byrow = TRUE, ncol = 9)

xt = x_init
print(xt)
for (t in 1:256) {
    message(t)
    xt = P %*% xt
    print(sum(xt))
}

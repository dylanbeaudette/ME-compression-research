library(aqp)
library(mvtnorm)
library(hexbin)
library(tactile)
library(lattice)

a <- rnorm(n = 100)
b <- rep(mean(a), times = length(a))
a <- format(a, digits = 4)
b <- format(b, digits = 4)

length(memCompress(a, type = 'gzip')) / length(memCompress(b, type = 'gzip'))



aqp:::.prepareVector(1:10, d = 4)
aqp:::.prepareVariable(1:10, numericDigits = 4)
aqp:::.prepareVariable(c('A', 'A', 'A', 'B', 'C'), numericDigits = 4)

# empty strings should always be 0
# adjusted for each compression type
aqp:::.compressedLength('', m = 'gzip')
aqp:::.compressedLength('', m = 'bzip2')
aqp:::.compressedLength('', m = 'xz')

# compression types
aqp:::.compressedLength(rep(letters, 100), m = 'gzip')
aqp:::.compressedLength(rep(letters, 100), m = 'bzip2')
aqp:::.compressedLength(rep(letters, 100), m = 'xz')


# note usage
aqp:::.compressedLength(1:10)
aqp:::.compressedLength(aqp:::.prepareVector(1:10))

aqp:::.compressedLength(1:10)
aqp:::.compressedLength(1)
aqp:::.compressedLength('AAA')
aqp:::.compressedLength(FALSE)

aqp:::.compressedLength(letters)
aqp:::.compressedLength('A')
aqp:::.compressedLength(factor('A'))


# NA should not "add" information
aqp:::.compressedLength(c('A', 'B', NA))
aqp:::.compressedLength(c('A', 'B', 'C'))
aqp:::.compressedLength(NA)

aqp:::.compressedLength(0)
aqp:::.compressedLength(1000)

aqp:::.compressedLength(c(1, 5, 10))
aqp:::.compressedLength(c(100, 500, 1000))

# single variable complexity vs. joint complexity
aqp:::.compressedLength(1:10) + aqp:::.compressedLength(20:30)
aqp:::.compressedLength(c(1:10, 20:30))

set.seed(101011)
sigma <- matrix(
  c(
    4, 3, 3, 
    3, 3, 3, 
    3, 3, 8
  ), ncol = 3)
n <- 10000
x <- rmvnorm(n = n, mean = c(10, 20, 30), sigma = sigma)
cor(x)

y <- cbind(
  runif(n, min = min(x), max = max(x)), 
  runif(n, min = min(x), max = max(x)),
  runif(n, min = min(x), max = max(x))
)
cor(y)

.cols <- hcl.colors(n = 100, palette = 'zissou 1')
.cp <- colorRampPalette(.cols)

hexplom(x, par.settings = tactile.theme(axis.text = list(cex = 0.66)), trans = log, inv = exp, xbins = 30, colramp = .cp, colorkey = FALSE, varname.cex = 0.75, varname.font = 2, xlab = '')

hexplom(y, par.settings = tactile.theme(axis.text = list(cex = 0.66)), trans = log, inv = exp, xbins = 30, colramp = .cp, colorkey = FALSE, varname.cex = 0.75, varname.font = 2, xlab = '')

aqp:::.compressedLength(c(x[, 1], x[, 2], x[, 3])) / aqp:::.compressedLength(c(y[, 1], y[, 2], y[, 3]))

# aqp:::.compressedLength(x[, 1]) / aqp:::.compressedLength(rep(mean(x[, 1], times = nrow(x))))
# aqp:::.compressedLength(y[, 1]) / aqp:::.compressedLength(rep(mean(y[, 1], times = nrow(x))))

aqp:::.compressedLength(c(x[, 1], x[, 2], x[, 3])) / 
  (aqp:::.compressedLength(x[, 1]) + aqp:::.compressedLength(x[, 2]) + aqp:::.compressedLength(x[, 3]))

aqp:::.compressedLength(c(y[, 1], y[, 2], y[, 3])) / 
  (aqp:::.compressedLength(y[, 1]) + aqp:::.compressedLength(y[, 2]) + aqp:::.compressedLength(y[, 3])) 



x <- c(1:5, 10:5)

d <- data.frame(
  source = aqp:::.compressedLength(x),
  rep.mean = aqp:::.compressedLength(rep(mean(x), times = length(x))),
  runif = aqp:::.compressedLength(runif(n = length(x), min = 0, max = 10))
)

knitr::kable(
  d, 
  caption = 'Length of gzip compressed objects (bytes).', 
  col.names = c('x: c(1:5, 10:5)', 'rep(mean(x, length(x)))', 'runif(length(x), min = 0, max = 10)')
)



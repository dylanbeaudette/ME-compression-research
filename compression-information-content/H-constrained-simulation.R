library(aqp)
library(extraDistr)
library(lattice)
library(tactile)



vizH <- function(p) {
  .txt <- sprintf("Pr = [%s]", paste(round(p / sum(p), 2), collapse = ', '))
  .Hmax <- shannonEntropy(rep(1, times = length(p)) / length(p))
  
  x <- rmultinom(n = 1000, size = 100, prob = p) / 100
  .H <- apply(x, 2, shannonEntropy)
  
  
  hist(.H, las = 1, xlim = c(0, .Hmax), cex.main = 1, main = .txt, xlab = '', ylab = '', axes = FALSE, border = 'royalblue', col = 'royalblue')
  axis(side = 1, at = seq(0, .Hmax, by = 0.25), cex.axis = 1)
  mtext('Shannon Entropy (base 2)', side = 1, line = 2, cex = 0.8)
  
  abline(v = median(.H), col = 'firebrick', lty = 2, lwd = 2)
}


# top-left to bottom-right: increasingly confused predictions
par(mfrow = c(3, 3), mar = c(3.5, 1, 2, 1))
vizH(c(64, 1, 1, 1))
mtext('Best', side = 3, line = -2)

vizH(c(32, 1, 1, 1))
vizH(c(32, 4, 2, 1))
vizH(c(32, 16, 1, 1))
vizH(c(64, 8, 8, 8))

vizH(c(32, 32, 16, 1))
vizH(c(16, 8, 8, 1))
vizH(c(16, 8, 4, 4))
vizH(c(1, 1, 1, 1))
mtext('Worst', side = 3, line = -2)


# from DGR
# 0.50, 0.50, 0, 0 -> 0.50, 0.40, 0.10, 0 -> 0.50, 0.40, 0.05, 0.05 -> 0.50, 0.30, 0.20, 0 -> 0.50, 0.30, 0.10, 0.10
# note: maybe use a "small" value instead of 0?
par(mfrow = c(1, 5), mar = c(3.5, 1, 2, 1))
vizH(c(50, 50, 0.01, 0.01))
vizH(c(50, 40, 10, 0.01))
vizH(c(50, 40, 5, 5))
vizH(c(50, 30, 20, 0.01))
vizH(c(50, 30, 10, 10))




#### related idea: H-field of a 3-class system ####

# max H = 1.584963

# starting with the full 3D array
s <- seq(0, 1, by = 0.01)
d <- expand.grid(x = s, y = s, z = s)

# constrain to 3-part simplex (x + y + z = 100)
idx <- which(rowSums(d) == 1)
d <- d[idx, ]

# 5151 rows
nrow(d)

# compute H, log base 2
d$H <- apply(d, 1, shannonEntropy, b = 2)

levelplot(
  H ~ x * y, 
  data = d, 
  cuts = 10,
  # at = seq(0, 1.6, length.out = 16),
  par.settings = tactile.theme(regions = list(col = hcl.colors(100, palette = 'mako'))),
  xlab = 'Pr(x)', 
  ylab = 'Pr(y)', 
  main = 'Shannon Entropy (log base 2)\n3-Class System (Hmax ~ 1.585)',
  asp = 1, 
  scales = list(tick.number = 10), 
  panel = function(...) {
    panel.levelplot(...)
    panel.points(0.33, 0.33, pch = 15, col = 1)
    panel.segments(x0 = 0, y0 = 0.33, x1 = 0.33, y1 = 0.33, lty = 2)
    panel.segments(x0 = 0.33, y0 = 0, x1 = 0.33, y1 = 0.33, lty = 2)
  }
)

levelplot(
  H/max(d$H) ~ x * y, 
  data = d, 
  at = c(0, c(0.95, 0.9, 0.85, 0.8), 1), 
  par.settings = tactile.theme(regions = list(col = c('royalblue', 'grey', 'orange', 'red', 'violet'))), 
  xlab = 'Pr(x)', 
  ylab = 'Pr(y)', 
  main = 'Shannon Entropy (log base 3)\n3-Class System',
  asp = 1, 
  scales = list(tick.number = 10), 
  panel = function(...) {
    panel.levelplot(...)
    panel.points(0.33, 0.33, pch = 15, col = 1)
    panel.segments(x0 = 0, y0 = 0.33, x1 = 0.33, y1 = 0.33, lty = 2)
    panel.segments(x0 = 0.33, y0 = 0, x1 = 0.33, y1 = 0.33, lty = 2)
  }
)



# scale simplex area:
.area <- round(nrow(d) * 0.1)
.idx <- order(d$H, decreasing = TRUE)[1:.area]

d$area_thresh <- 0
d$area_thresh[.idx] <- 1

levelplot(
  area_thresh ~ x * y, 
  data = d, 
  at = c(0, 0.5, 1),
  colorkey = FALSE,
  par.settings = tactile.theme(regions = list(col = c('royalblue', 'red'))), 
  xlab = 'Pr(x)', 
  ylab = 'Pr(y)', 
  main = 'Shannon Entropy (10% Simplex Area Threshold)\n3-Class System',
  asp = 1, 
  scales = list(tick.number = 10), 
  panel = function(...) {
    panel.levelplot(...)
    panel.points(0.33, 0.33, pch = 15, col = 1)
    panel.segments(x0 = 0, y0 = 0.33, x1 = 0.33, y1 = 0.33, lty = 2)
    panel.segments(x0 = 0.33, y0 = 0, x1 = 0.33, y1 = 0.33, lty = 2)
  }
)


# H as a function of n
n.seq <- 2:30
H <- sapply(n.seq, function(i) shannonEntropy(rep(1/i, times = i), b = 2))
d <- data.frame(n = n.seq, H = H)

cols <- hcl.colors(n = 5, palette = "zissou1")[c(1, 5)]

xyplot(H ~ n, 
       data = d, 
       ylim = c(0, max(d$H) + 0.25),
       xlab = 'Number of Classes', 
       ylab = 'Shannon Entropy (log base 2)', 
       scales = list(tick.number = 15), 
       col = 'royalblue', 
       lwd = 3, 
       main = 'Equal Class Probability', 
       panel = function(x, y, ...) {
         panel.xyplot(x = x, y = y, ..., type=c('l', 'g'))
         
         .s <- c(0.95, 0.9, 0.75, 0.5)
         for(i in .s) {
           .txt <- sprintf("%s%%", i * 100)
           panel.lines(x = x, y = y * i, lty = 2, lwd = 1.5)
           panel.text(x = max(x), y = y[length(y)] * i, label = .txt, font = 2, cex = 0.8, pos = 4)
         }
       }
)





#################### Haven't figured this part out yet ####################



## brute force approach: full grid / limited to those values than sum to 1
# this is really stupid and will not scale

g <- expand.grid(
  seq(0, 1, by = 0.05), 
  seq(0, 1, by = 0.05), 
  seq(0, 1, by = 0.05), 
  seq(0, 1, by = 0.05)
)

idx <- which(rowSums(g) == 1)
g <- g[idx, ]

nrow(g)

g$H <- apply(g, 1, shannonEntropy)



hist(g$H)

g$obj <- (g$H - 1.5)^2

hist(g$obj)
quantile(g$obj)

table(g$obj == 0)
idx <- which(g$obj == 0)

g[idx, ]

which.min(g$obj[-idx])
g[10, ]

idx <- order(g$obj)[1:20]
g[idx, ]



## smarter approach, the class-specific probabilities don't matter, 
## just the unique vector of probabilities
## ... but how to generate start / iteration, subject to sum == 1?




## try optimization over multinominal simulation
## what is a reasonable objective function?

f.m <- function(a, n = 100) {
  x <- rmultinom(n = n, size = 100, prob = a) / 100
  
  .e <- apply(x, 2, shannonEntropy)
  return(.e)
}

# objective function
E <- function(par, target) {
  .e <- f.m(a = par, n = 1)
  
  .obj <- abs(target - .e)
  
  return(.obj)
}











E(par = c(1, 1, 1, 1), target = 2)
E(par = c(1, 1, 1, 1), target = 1)

o <- optim(par = c(1, 1, 1, 1), fn = E, target = 1, method = 'L-BFGS-B', lower = 1, upper = 100)
o
round(o$par / max(o$par), 2)
hist(f.m(n = 1000, a = o$par), breaks = 30)

vizH(o$par)



f.d <- function(a, n = 100) {
  x <- suppressWarnings(rdirichlet(n = n, alpha = a))
  .e <- apply(x, 1, shannonEntropy)
  return(.e)
}








E(par = c(1, 1, 1, 1), target = 2)
E(par = c(1, 1, 1, 1), target = 0.5)

hist(f.m(n = 1000, a = c(0.5, 0.01, 0.01, 0.03)), breaks = 30)

hist(f.m(n = 1000, a = c(0.3, 0.01, 0.001, 0.001)), breaks = 30)



o <- optim(par = c(1, 1, 1, 1), fn = E, target = 1, method = 'L-BFGS-B', lower = 0.0001, upper = 1)
o$par
o

hist(f.m(n = 1000, a = o$par), breaks = 30)


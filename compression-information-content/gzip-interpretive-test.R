## ideas:
# https://scottaaronson.blog/?p=762


## TODO: 
## * generalize into a new function
## * compare gzip vs. bzip2 --> interesting differences when data are "small"
## * short-range vs. long-range patterns


library(lorem)
cols <- hcl.colors(n = 5, palette = 'zissou1', rev = TRUE)


# Moby Dick
# https://www.gutenberg.org/files/2701/old/moby10b.txt
md.book <- readLines('moby-dick.txt')
md.book <- md.book[which(md.book != '')]

# number of samples
s <- c(10, 30, 50, 100, 300, 500, 1000, 3000, 5000, 10000, 30000, 50000)


sim.letters <- sapply(s, function(i) {
  a <- sample(letters, size = i, replace = TRUE)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

sim.runif <- sapply(s, function(i) {
  a <- runif(n = i)
  a <- format(a, digits = 10)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

 sim.single.letter <- sapply(s, function(i) {
  a <- rep('a', times = i)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

sim.ipsum.words <- sapply(s, function(i) {
  a <- ipsum_words(n = i, collapse = TRUE)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

sim.md <- sapply(s, function(i) {
  a <- sample(md.book, size = i, replace = TRUE)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})




options(scipen = 10)

ragg::agg_png(filename = 'figures/gzip-demonstration.png', width = 900, height = 900, scaling = 1.5)

par(mar = c(4.5, 4.5, 3, 1), bg = 'black', fg = 'white', col.axis = 'white', col.lab = 'white')

plot(
  s, 
  x, 
  type = 'n', 
  las = 1, 
  ylab = 'gzip Compressed Size (kb)', 
  xlab = 'Number of Samples with Replacement',
  log = 'xy',
  ylim = c(0.01, max(md)),
  axes = FALSE
)

grid(col = par('fg'))
lines(s, sim.single.letter, type = 'b', col = cols[1], lty = 2, lwd = 2, pch = 16)
lines(s, sim.letters, type = 'b', col = cols[2], lwd = 2, pch = 16)
lines(s, sim.ipsum.words, type = 'b', col = cols[3], lwd = 2, pch = 16)
lines(s, sim.runif, type = 'b', col = cols[4], lwd = 2, pch = 16)
lines(s, sim.md, type = 'b', col = cols[5], lwd = 2, pch = 16)

legend(
  'topleft', 
  legend = c('replicated constant', 'samples from `letters`', 'lorem ipsum words', 'format(runif(), digits = 10)', 'lines from Moby Dick'), 
  lwd = 2, 
  lty = c(2, 1, 1, 1, 1),
  col = cols, 
  box.col = NA
)

axis(side = 2, las = 1, cex.axis = 0.8)
axis(side = 1, las = 1, cex.axis = 0.8, at = s)

dev.off()

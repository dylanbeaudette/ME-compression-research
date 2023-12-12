## ideas:
# https://scottaaronson.blog/?p=762


library(lorem)

s <- c(10, 30, 50, 100, 300, 500, 1000, 3000, 5000, 10000, 30000, 50000)


x <- sapply(s, function(i) {
  a <- sample(letters, size = i, replace = TRUE)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

y <- sapply(s, function(i) {
  a <- runif(n = i)
  a <- format(a, digits = 10)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

z <- sapply(s, function(i) {
  a <- rep('a', times = i)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})

li <- sapply(s, function(i) {
  a <- ipsum_words(n = i, collapse = TRUE)
  l <- length(memCompress(paste0(a, collapse = ''), type = 'gzip'))
  l / 1024
})


options(scipen = 10)

ragg::agg_png(filename = 'figures/lorem-test.png', width = 900, height = 900, scaling = 1.5)

par(mar = c(4.5, 4.5, 3, 1))

plot(
  s, 
  x, 
  type = 'n', 
  las = 1, 
  ylab = 'gzip length (kb)', 
  xlab = 'sequence length',
  log = 'xy',
  ylim = c(0.01, max(y)),
  axes = FALSE
)

grid()
lines(s, x, type = 'b', col = 1, lwd = 2)
lines(s, y, type = 'b', col = 4, lwd = 2)
lines(s, z, type = 'b', col = 2, lwd = 2)
lines(s, li, type = 'b', col = 3, lwd = 2)


legend(
  'topleft', 
  legend = c('samples from `letters`', 'lorem ipsum words', 'format(runif(), digits = 10)', 'replicated constant'), 
  lwd = 2, 
  col = c(1, 3, 4, 2), 
  bty = 'n'
)

axis(side = 2, las = 1, cex.axis = 0.8)
axis(side = 1, las = 1, cex.axis = 0.8)

dev.off()

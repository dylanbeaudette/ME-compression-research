library(aqp)

# single horizon, constant value
p1 <- data.frame(id = 1, top = 0, bottom = 100, p = 5, name = 'H')

# multiple horizons, constant value
p2 <- data.frame(
  id = 2, top = c(0, 10, 20, 30, 40, 50),
  bottom = c(10, 20, 30, 40, 50, 100),
  p = rep(5, times = 6),
  name = c('A1', 'A2', 'Bw', 'Bt1', 'Bt2', 'C')
)

# multiple horizons, random values
p3 <- data.frame(
  id = 3, top = c(0, 10, 20, 30, 40, 50),
  bottom = c(10, 20, 30, 40, 50, 100),
  p = c(5, 8, 10, 35, 6, 2),
  name = c('A1', 'A2', 'Bw', 'Bt1', 'Bt2', 'C')
)

# multiple horizons, mostly NA
p4 <- data.frame(
  id = 4, top = c(0, 10, 20, 30, 40, 50),
  bottom = c(10, 20, 30, 40, 50, 100),
  p = c(5, NA, NA, NA, NA, NA),
  name = c('A1', 'A2', 'Bw', 'Bt1', 'Bt2', 'C')
)

# shallower version of p1
p5 <- data.frame(id = 5, top = 0, bottom = 50, p = 5, name = 'H')

# combine and upgrade to SPC
z <- rbind(p1, p2, p3, p4, p5)
depths(z) <- id ~ top + bottom
hzdesgnname(z) <- 'name'

# factor version of horizon name
z$fname <- factor(z$name)


a <- dice(z[3, ])
a$p <- runif(n = nrow(a), min = 0, max = 40)
a$name <- NA
profile_id(a) <- '6'

b <- a
b$p <- sort(b$p, decreasing = TRUE)
b$name <- NA
profile_id(b) <- '7'

z <- combine(z, a, b)


vars <- c('p', 'name')
pi <- profileInformationIndex(z, vars = vars, method = 'j', compression = 'gzip')
pi.b <- profileInformationIndex(z, vars = vars, method = 'j', baseline = TRUE, compression = 'gzip')


# visual check
.args <- list(width = 0.33, color = 'p', name.style = 'center-center', cex.names = 0.75, max.depth = 110, col.legend.cex = 0.8, lwd = 0.33, depth.axis = list(line = -1, cex = 0.75, style = 'compact'), col.label = 'property')
options(.aqp.plotSPC.args = .args)

ragg::agg_png(filename = 'figures/simple-demonstration.png', width = 1200, height = 550, scaling = 1.5)

par(mar = c(1, 0, 3, 3), mfcol = c(1, 2))
plotSPC(z)
text(x = 1:length(z), y = 105, labels = pi, cex = 0.85)
mtext('Profile Information Index (bytes)', side = 1, line = -0.5)

plotSPC(z)
text(x = 1:length(z), y = 105, labels = signif(pi.b, digits = 4), cex = 0.85)
mtext('Profile Complexity Ratio', side = 1, line = -0.5)

dev.off()




# effect of aggregation function
profileInformationIndex(z, vars = vars, method = 'i', baseline = FALSE)
profileInformationIndex(z, vars = vars, method = 'j', baseline = FALSE)

# effect of compression
profileInformationIndex(z, vars = vars, method = 'j', baseline = FALSE, compression = 'gzip')
profileInformationIndex(z, vars = vars, method = 'j', baseline = FALSE, compression = 'bzip2')
profileInformationIndex(z, vars = vars, method = 'j', baseline = FALSE, compression = 'xz')
profileInformationIndex(z, vars = vars, method = 'j', baseline = FALSE, compression = 'none')

# effect of baseline
profileInformationIndex(z, vars = vars, method = 'j', baseline = TRUE)
profileInformationIndex(z, vars = vars, method = 'j', baseline = FALSE)

# effect of padding depths, only when vars includes top/bottom
profileInformationIndex(z, vars = c(vars, 'top'), method = 'j', baseline = FALSE, padNA = TRUE)
profileInformationIndex(z, vars = c(vars, 'top'), method = 'j', baseline = FALSE, padNA = FALSE)

# effect of number digits in character representation
profileInformationIndex(z, vars = vars, method = 'j', baseline = TRUE, numericDigits = 1)
profileInformationIndex(z, vars = vars, method = 'j', baseline = TRUE, numericDigits = 10)


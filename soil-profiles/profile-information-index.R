
library(soilDB)
library(lattice)
library(tactile)
library(hexbin)
library(purrr)
library(mvtnorm)

## TODO:
# * what is the baseline? 
# * compressed vs. raw
# * compressed values vs. compressed (mean or constant level factors)
# * Shannon H and differential entropy
# * joint vs. individual compression may not be doing what I think it is doing
# * effect of flattening character vectors?
# * joint and individual may be the same thing
# * compressed vs. un-compressed length may be meaningful (e.g. normalized)


## related literature
# https://acsess.onlinelibrary.wiley.com/doi/pdf/10.2136/sssaj2011.0130
# https://www.sciencedirect.com/science/article/pii/S0016706122004360
# https://www.mdpi.com/1099-4300/16/6/3482
# https://www.jstor.org/stable/41490412
# 

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










### simple cases

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

par(mar = c(1, 0, 3, 3), mfcol = c(1, 2))
plotSPC(z)
text(x = 1:length(z), y = 105, labels = pi, cex = 0.85)
mtext('Profile Information Index (bytes)', side = 1, line = -0.5)

plotSPC(z)
text(x = 1:length(z), y = 105, labels = signif(pi.b, digits = 4), cex = 0.85)
mtext('Profile Complexity Ratio', side = 1, line = -0.5)



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





## for later, distance matrices

d <- NCSP(z, vars = c('p', 'fname'), maxDepth = 100)
d <- as.matrix(d)
d

aqp:::.compressedLength(d)

# m <- d
# m[] <- d[sample(1:length(d))]
# aqp:::.compressedLength(m)





## truncate





# s <- c('holland', 'sierra', 'musick', 'hanford', 'grangeville', 'delhi', 'amador', 'cecil', 'leon', 'lucy', 'clarksville', 'zook', 'clear lake', 'yolo', 'calhi', 'corralitos', 'sacramento', 'dodgeland')
# x <- fetchOSD(s)
# 
# x <- trunc(x, 0, 100)
# 
# vars <- c('hue', 'value', 'chroma', 'texture_class', 'cf_class', 'pH', 'pH_class', 'distinctness', 'topography')
# 
# x$pi <- profileInformationIndex(x, vars = vars, baseline = FALSE, method = 'median')
# 
# par(mar = c(3, 0, 1, 2))
# plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE)
# axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
# title('baseline = FALSE, method = median')
# 




options(.aqp.plotSPC.args = NULL)

s <- c('holland', 'sierra', 'musick', 'hanford', 'grangeville', 'delhi', 'amador', 'cecil', 'leon', 'lucy', 'clarksville', 'zook', 'clear lake', 'yolo', 'calhi', 'corralitos', 'sacramento', 'dodgeland')
x <- fetchOSD(s)

# vars <- c('hue', 'value', 'chroma', 'texture_class', 'cf_class', 'pH', 'pH_class', 'distinctness', 'topography')


par(mar = c(3, 0, 1, 2), mfrow = c(2, 1))

vars <- c('hue', 'value', 'chroma', 'hzname')

x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = FALSE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('Profile Information Index (bytes)')


x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('Profile Complexity Ratio')




pdf(file = 'e:/temp/profileInformationIndex-test.pdf', width = 11, height = 8.5, pointsize = 10)

par(mar = c(3, 0, 1, 2), mfrow = c(2, 1))

vars <- c('hue', 'value', 'chroma', 'hzname')

x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = FALSE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = j, baseline = FALSE', cex.main = 1)

x$pi <- profileInformationIndex(x, vars = vars, method = 'i', baseline = FALSE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = i, baseline = FALSE', cex.main = 1)


x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = j, baseline = TRUE', cex.main = 1)

x$pi <- profileInformationIndex(x, vars = vars, method = 'i', baseline = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = i, baseline = TRUE', cex.main = 1)


# add top depth to test padNA = TRUE
vars <- c('hue', 'value', 'chroma', 'hzname', 'top')

x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = FALSE, padNA = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = j, baseline = FALSE, padNA = TRUE', cex.main = 1)

x$pi <- profileInformationIndex(x, vars = vars, method = 'i', baseline = FALSE, padNA = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = i, baseline = FALSE, padNA = TRUE', cex.main = 1)


x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = TRUE, padNA = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = j, baseline = TRUE, padNA = TRUE', cex.main = 1)

x$pi <- profileInformationIndex(x, vars = vars, method = 'i', baseline = TRUE, padNA = TRUE)

plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE, max.depth = 200)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)
title('method = i, baseline = TRUE, padNA = TRUE', cex.main = 1)


dev.off()







.lab <- convertColor(t(col2rgb(x$soil_color)) / 255, from = 'sRGB', to = 'Lab', from.ref.white = 'D65', to.ref.white = 'D65')


x$L <- .lab[, 1]
x$A <- .lab[, 2]
x$B <- .lab[, 3]


x$pi <- profileInformationIndex(x, vars = c('L', 'A', 'B'), baseline = FALSE, method = 'j')

par(mar = c(3, 0, 1, 2), mfrow = c(1,1))
plotSPC(x, width = 0.3, name.style = 'center-center', plot.order = order(x$pi), cex.names = 0.66, shrink = TRUE)
axis(side = 1, at = 1:length(x), labels = format(x$pi, digits = 3)[order(x$pi)], cex.axis = 0.75, las = 1)




vars <- c('hue', 'value', 'chroma', 'texture_class', 'cf_class', 'pH', 'pH_class', 'distinctness', 'topography')

z <- data.frame(
  baseline.j = profileInformationIndex(x, vars = vars, baseline = TRUE, method = 'j'),
  j = profileInformationIndex(x, vars = vars, baseline = FALSE, method = 'j'),
  baseline.i = profileInformationIndex(x, vars = vars, baseline = TRUE, method = 'i'),
  median.i = profileInformationIndex(x, vars = vars, baseline = FALSE, method = 'i')
)

cor(z)
splom(z, par.settings = tactile.theme())


sc <- data.table::fread('https://github.com/ncss-tech/SoilWeb-data/raw/main/files/SC-database.csv.gz')
sc <- as.data.frame(sc)

sc.sub <- subset(sc, subset = taxgrtgroup %in% c('haploxeralfs', 'haploxerepts', 'palexeralfs', 'xerorthents', 'haploxererts', 'endoaquolls'))

table(sc.sub$taxgrtgroup)

s <- sc.sub$soilseriesname
s <- split(s, makeChunks(s, size = 20))

x <- map(
  s,
  .progress = TRUE,
  .f = function(i) {
    fetchOSD(i)
  })

x <- combine(x)

vars <- c('hzname', 'hue', 'value', 'chroma', 'texture_class')

# data.table: 44 seconds
# profileApply:
system.time(
  z <- data.frame(
    baseline.joint = profileInformationIndex(x, vars = vars, baseline = TRUE, method = 'j', padNA = FALSE),
    baseline.individual = profileInformationIndex(x, vars = vars, baseline = TRUE, method = 'i', padNA = FALSE),
    joint = profileInformationIndex(x, vars = vars, baseline = FALSE, method = 'j', padNA = FALSE),
    individual = profileInformationIndex(x, vars = vars, baseline = FALSE, method = 'i', padNA = FALSE)
  )
)

cor(z)

.cols <- hcl.colors(n = 100, palette = 'zissou 1')
.cp <- colorRampPalette(.cols)

hexplom(z, par.settings = tactile.theme(axis.text = list(cex = 0.66)), trans = log, inv = exp, xbins = 30, colramp = .cp, colorkey = FALSE, varname.cex = 0.75, varname.font = 2, main = 'Profile Information Index', xlab = '')


## interesting... very little difference between joint vs. individual


plot(joint ~ individual, data = z, las = 1)
plot(baseline.joint ~ baseline.individual, data = z, las = 1)
hexbinplot(baseline.joint ~ joint, data = z, par.settings = tactile.theme(), trans = log, inv = exp, xbins = 30, colramp = .cp, colorkey = FALSE, varname.cex = 0.75, varname.font = 2, main = 'Profile Information Index')


## Profile Complexity Ratio (baseline = TRUE): less influenced by number of horizons
## --> cor ~ 0.44

## Profile Complexity Index (baseline = FALSE): more influenced by number of horizons 
## --> cor ~ 0.71

x$pi <- profileInformationIndex(x, vars = vars, method = 'j', baseline = FALSE, padNA = FALSE)
x$nhz <- profileApply(x, FUN = nrow, simplify = TRUE)

x$greatgroup <- factor(x$greatgroup, levels = c('palexeralfs', 'haploxeralfs', 'haploxerepts', 'xerorthents', 'haploxererts', 'endoaquolls'))

dev.off()
options(.aqp.plotSPC.args = NULL)
hist(x$pi, las = 1, breaks = 20, xlab = 'Profile Information Index (baseline sum)', main = '')

# .crit <- mean(x$pi) + (c(-2, 2) * sd(x$pi))
.crit <- quantile(x$pi, probs = c(0.01, 0.99))

par(mar = c(0, 0, 0, 2))
plotSPC(x[x$pi > .crit[2], ], width = 0.3, name.style = 'center-center', cex.names = 0.66, shrink = TRUE, max.depth = 250)

plotSPC(x[x$pi < .crit[1], ], width = 0.3, name.style = 'center-center', cex.names = 0.66, shrink = TRUE, max.depth = 250)





bwplot(greatgroup ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Information Index')

bwplot(greatgroup ~ nhz, data = site(x), par.settings = tactile.theme(), varwidth = TRUE, notch = TRUE, xlab = 'Number of Horizons')

bwplot(pi ~ factor(nhz) | greatgroup, data = site(x), par.settings = tactile.theme(), ylab = 'Profile Information Index', xlab = 'Number of Horizons')


hexbinplot(pi ~ nhz | greatgroup, data = site(x), par.settings = tactile.theme(), ylab = 'Profile Information Index', xlab = 'Number of Horizons', trans = log, inv = exp, xbins = 10, colramp = .cp, colorkey = FALSE)



cor(x$nhz, x$pi)



library(ggdist)
library(ggplot2)

ggplot(site(x), aes(x = pi, y = greatgroup)) +
  stat_interval(inherit.aes = TRUE, orientation = 'horizontal', size = 6) + 
  theme_minimal() +
  theme(legend.position = c(1, 1), legend.justification ='right', legend.direction	
        = 'horizontal', legend.background = element_rect(fill = 'white', color = NA), axis.text.y = element_text(face = 'bold')) + 
  stat_summary(geom = 'point', fun = median, shape = 21, fill = 'black', col = 'white', cex = 3) +
  scale_color_brewer() + 
  scale_x_continuous(n.breaks = 16) +
  xlab('Profile Information Index (bytes)') + ylab('') +
  labs(title = 'Profile Information Index for Select Greatgroup Taxa', color = 'Interval')


##### 



z1 <- lapply(letters[1:10], random_profile, n = 5, exact = TRUE, n_prop = 3, SPC = TRUE, method = 'LPP')
z1 <- combine(z1)

z2 <- lapply(letters[11:20], random_profile, n = 5, exact = TRUE, n_prop = 3, SPC = TRUE)
z2 <- combine(z2)

site(z1)$g <- 'LPP'
site(z2)$g <- 'RW'

z <- combine(z1, z2)

## important: scales may be very different, scale() -> compress

z$pi <- profileInformationIndex(z, vars = c('p1', 'p2', 'p3'), method = 'j', scaleNumeric = TRUE)
z$nhz <- profileApply(z, FUN = nrow, simplify = TRUE)

z$g <- factor(z$g)

z$pi
z$nhz

par(mar = c(0, 0, 3, 2))
groupedProfilePlot(z, groups = 'g', color = 'p1')

lsp <- get('last_spc_plot', envir = aqp.env)

o <- lsp$plot.order
.b <- z[, , .LAST, .BOTTOM]

text(x = o, y = .b, labels = z$pi, cex = 0.66, pos = 1)


bwplot(g ~ pi, data = site(z))



z1 <- lapply(
  1:50, 
  random_profile, 
  n = 5, 
  exact = TRUE, 
  n_prop = 3, 
  SPC = TRUE, 
  method = 'LPP', 
  lpp.a = 5, 
  lpp.b = 10, 
  lpp.d = 5, 
  lpp.e = 5, 
  lpp.u = 25, 
  min_thick = 2, 
  max_thick = 50
)

z1 <- combine(z1)
# z1 <- trunc(z1, 0, min(z1))

z1$pi <- profileInformationIndex(z1, vars = c('p1', 'p2', 'p3'), method = 'j', scale = TRUE, baseline = TRUE, padNA = FALSE)

par(mar = c(3, 0, 0, 2))
plotSPC(z1, color = 'p1', plot.order = order(z1$pi), print.id = FALSE, width = 0.35, divide.hz = FALSE)
axis(side = 1, at = 1:length(z1), labels = format(z1$pi[order(z1$pi)], digits = 3), cex.axis = 0.66)


z1$pi <- profileInformationIndex(z1, vars = c('p1', 'p2', 'p3'), method = 'j', scale = TRUE, baseline = FALSE, padNA = FALSE)

par(mar = c(3, 0, 0, 2))
plotSPC(z1, color = 'p1', plot.order = order(z1$pi), print.id = FALSE, width = 0.35, divide.hz = FALSE)
axis(side = 1, at = 1:length(z1), labels = format(z1$pi[order(z1$pi)], digits = 3), cex.axis = 0.66)



z1 <- lapply(
  1:10000, 
  random_profile, 
  n = 5, 
  exact = TRUE, 
  n_prop = 3, 
  SPC = TRUE, 
  method = 'LPP', 
  lpp.a = 5, 
  lpp.b = 10, 
  lpp.d = 5, 
  lpp.e = 5, 
  lpp.u = 25, 
  min_thick = 2, 
  max_thick = 50
)

z1 <- combine(z1)

# 1k  : 4.6 seconds
# 10k : 55 seconds
system.time(
  old <- profileInformationIndex(z1, vars = c('p1', 'p2', 'p3'), method = 'j', scale = TRUE, baseline = TRUE, padNA = FALSE)
)

# 1k  : 1.56 seconds
# 10k : 18 seconds
system.time(
  new <- profileInformationIndex(z1, vars = c('p1', 'p2', 'p3'), method = 'j', scale = TRUE, baseline = TRUE, padNA = FALSE)
)


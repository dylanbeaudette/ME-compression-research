
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




## for later, distance matrices

d <- NCSP(z, vars = c('p', 'fname'), maxDepth = 100)
d <- as.matrix(d)
d

aqp:::.compressedLength(d)

# m <- d
# m[] <- d[sample(1:length(d))]
# aqp:::.compressedLength(m)






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



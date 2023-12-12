library(aqp)
library(lattice)
library(tactile)
library(hexbin)
library(SoilTaxonomy)


# toggle to re-create from sources
reMakeCachedData <- FALSE

if(reMakeCachedData) {
  
  # SC database
  sc <- read.csv('e:/working_copies/SoilWeb-data/files/SC-database.csv.gz')
  names(sc)[2] <- 'seriesname'
  
  # latest OSD morphology + colors
  x <- read.csv('e:/working_copies/SoilWeb-data/OSD/parsed-data-est-colors.csv.gz')
  
  # init SPC
  depths(x) <- seriesname ~ top + bottom
  hzdesgnname(x) <- 'name'
  
  # fix old-style O horizons
  x <- accumulateDepths(x)
  
  # ~ 23.7k
  x <- HzDepthLogicSubset(x)
  length(x)
  
  # merge classification details from SC
  site(x) <- sc
  
  # init factors
  data("ST_unique_list")
  ST_unique_list$order
  x$taxorder <- factor(x$taxorder, levels = ST_unique_list$order)
  x$taxsuborder <- factor(x$taxsuborder, levels = ST_unique_list$suborder)
  
  # remove series missing a soil order classification
  x <- subset(x, !is.na(taxorder))
  
  # convert Munsell color notation -> CIELAB
  .lab <- munsell2rgb(x$moist_hue, x$moist_value, x$moist_chroma, returnLAB = TRUE)
  .lab$hzID <- x$hzID
  horizons(x) <- .lab
  
  # save for later use
  saveRDS(x, file = 'data/cached-OSDs.rds')
  
} else {
  # load cached, prepared data
  x <- readRDS(file = 'data/')
}

## profile information index and baseline

# variables of interest
# to define "information content"
.v <- c('L', 'A', 'B', 'texture_class', 'distinctness', 'topography')

# ~ 50 seconds
system.time(
  x$pi <- profileInformationIndex(x, vars = .v, method = 'joint', baseline = FALSE, scaleNumeric = FALSE, padNA = FALSE)
)

# ~ 90 seconds
system.time(
  x$pc.ratio <- profileInformationIndex(x, vars = .v, method = 'joint', baseline = TRUE, scaleNumeric = FALSE, padNA = FALSE)
)


## think about the results

histogram(x$pi, breaks = 80, par.settings = tactile.theme(), xlab = 'Profile Information Index (bytes)', main = 'Official Soil Series Descriptions')

histogram(x$pc.ratio, breaks = 80, par.settings = tactile.theme(), xlab = 'Profile Complexity Ratio', main = 'Official Soil Series Descriptions')

ragg::agg_png(filename = 'figures/OSD-soilorder-PII.png', width = 1000, height = 500, scaling = 1.5)

bwplot(taxorder ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), notch = TRUE, xlab = 'Profile Information Index (bytes)', scales = list(x = list(tick.number = 10)))

dev.off()


bwplot(taxorder ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Information Index (bytes)', scales = list(x = list(tick.number = 10)))

bwplot(taxorder ~ pc.ratio, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Complexity Ratio', scales = list(x = list(tick.number = 10)))

ragg::agg_png(filename = 'figures/OSD-suborder-entisols-PII.png', width = 800, height = 400, scaling = 1.5)

bwplot(taxsuborder ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Information Index (bytes)', subset = taxorder == 'entisols', scales = list(x = list(tick.number = 10)))

dev.off()

bwplot(taxsuborder ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Information Index (bytes)', subset = taxorder == 'alfisols', scales = list(x = list(tick.number = 10)))

bwplot(taxsuborder ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Information Index (bytes)', subset = taxorder == 'mollisols', scales = list(x = list(tick.number = 10)))

bwplot(taxsuborder ~ pi, data = site(x), par.settings = tactile.theme(axis.text = list(cex = 1)), varwidth = TRUE, notch = TRUE, xlab = 'Profile Information Index (bytes)', subset = taxorder == 'alfisols', scales = list(x = list(tick.number = 10)))


library(ggdist)
library(ggplot2)


ragg::agg_png(filename = 'figures/OSD-soilorder-PII-gg.png', width = 1000, height = 500, scaling = 1.5)

ggplot(site(x), aes(x = pi, y = taxorder)) +
  stat_interval(inherit.aes = TRUE, orientation = 'horizontal', size = 6) + 
  theme_minimal() +
  theme(legend.position = c(1, 1), legend.justification ='right', legend.direction	
        = 'horizontal', legend.background = element_rect(fill = 'white', color = NA), axis.text.y = element_text(face = 'bold')) + 
  stat_summary(geom = 'point', fun = median, shape = 21, fill = 'black', col = 'white', cex = 3) +
  scale_color_brewer() + 
  scale_x_continuous(n.breaks = 16) +
  xlab('Profile Information Index (bytes)') + ylab('') +
  labs(title = 'Profile Information Index for OSDs', color = 'Interval')

dev.off()

ggplot(site(x), aes(x = pc.ratio, y = taxorder)) +
  stat_interval(inherit.aes = TRUE, orientation = 'horizontal', size = 6) + 
  theme_minimal() +
  theme(legend.position = c(1, 1), legend.justification ='right', legend.direction	
        = 'horizontal', legend.background = element_rect(fill = 'white', color = NA), axis.text.y = element_text(face = 'bold')) + 
  stat_summary(geom = 'point', fun = median, shape = 21, fill = 'black', col = 'white', cex = 3) +
  scale_color_brewer() + 
  scale_x_continuous(n.breaks = 16) +
  xlab('Profile Complexity Ratio') + ylab('') +
  labs(title = 'Profile Complexity for OSDs', color = 'Interval')


quantile(x$pi, probs = c(0.001, 0.5, 0.999))

z <- subset(x, pi > 350)
length(z)

z$soilcolor <- munsell2rgb(z$moist_hue, z$moist_value, z$moist_chroma)
z$hzd <- hzDistinctnessCodeToOffset(z$distinctness)



ragg::agg_png(filename = 'figures/OSD-top15-complex.png', width = 1500, height = 900, scaling = 1.5)

par(mar = c(2.5, 0, 2, 1))
plotSPC(z[sample(1:length(z), size = 15), ], color = 'soilcolor', name.style = 'center-center', max.depth = 250, cex.names = 0.6, depth.axis = list(style = 'compact', line = -3, cex = 0.8), width = 0.4, id.style = 'top', cex.id = 0.75, hz.distinctness.offset = 'hzd')
title('Profile Information Index of Select OSDs')
mtext("15 Most Complex Soil Series", side = 1, at = 0.5, adj= 0, line = 1)

dev.off()


z <- subset(x, seriesname %in% c('AMADOR', 'LUCY', 'PIERRE', 'LEON', 'ZOOK', 'CLARION', 'DRUMMER', 'COLUMBIA', 'DELHI'))

z$soilcolor <- munsell2rgb(z$moist_hue, z$moist_value, z$moist_chroma)
z$hzd <- hzDistinctnessCodeToOffset(z$distinctness)



o <- order(z$pi)

ragg::agg_png(filename = 'figures/OSD-select-example.png', width = 1200, height = 700, scaling = 1.5)

par(mar = c(2.5, 0, 2, 0))
plotSPC(z, color = 'soilcolor', plot.order = o, name.style = 'center-center', max.depth = 205, cex.names = 0.75, hz.depths = TRUE, depth.axis = FALSE, width = 0.33, hz.distinctness.offset = 'hzd')
title('Profile Information Index of Select OSDs')

axis(side = 1, at = 1:length(z), labels = round(z$pi[o], 1), cex.axis = 0.8)

dev.off()


o <- order(z$pc.ratio)

par(mar = c(2.5, 0, 2, 0))
plotSPC(z, color = 'soilcolor', plot.order = o, name.style = 'center-center', max.depth = 205, cex.names = 0.75, hz.depths = TRUE, depth.axis = FALSE, width = 0.33)
title('Profile Complexity Ratio of Select OSDs')

axis(side = 1, at = 1:length(z), labels = round(z$pc.ratio[o], 1), cex.axis = 0.8)




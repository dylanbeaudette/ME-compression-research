# https://r-spatial.github.io/gstat/reference/predict.gstat.html

library(gstat)
library(sp)
library(terra)
library(raster)
library(viridis)
library(rasterVis)
library(sf)
library(soilDB)

#### fake data, used for a simple example

xy <- expand.grid(1:100, 1:100)
names(xy) <- c("x","y")
gridded(xy) = ~ x + y

# fake CRS
proj4string(xy) <- '+init=EPSG:5070'

m <- vgm(psill = 1, model = "Exp", range = 35)
plot(m, cutoff = 75)


g.dummy <- gstat(
  formula = z ~ 1, 
  dummy = TRUE, 
  beta = 5.9,
  model = m, 
  nmax = 10
)

## unconditional simulation

set.seed(101010)
p <- predict(g.dummy, newdata = xy, nsim = 1)

# SPDF -> raster -> rast
p <- rast(raster(p))
# fake crs
crs(p) <- 'EPSG:5070'

## sampling points for conditional simulation
set.seed(101010)
s <- spatSample(p, size = 50, method = 'random', as.points = TRUE)

plot(p, col = viridis(25), axes = FALSE)
points(s, cex = 1.5)

# SPDF for methods that require it
s.sp <- as(s, 'Spatial')


## conditional simulation
set.seed(101010)
sim <- krige(
  formula = sim1 ~ 1, 
  s.sp, 
  xy, 
  model = m, 
  nmax = 10, 
  beta = 5.9, 
  nsim = 4
)


sim <- rast(stack(sim))
# fake crs
crs(sim) <- 'EPSG:5070'

# check
plot(sim, col = viridis(25), axes = FALSE)

# consider classes for simpler interpretation
sim.class <- classify(sim, rcl = 6)
sim.class <- catalyze(sim.class)

## spatial analogue to Anscombe's Quartet
levelplot(
  sim.class, 
  col.regions = viridis,
  scales = list(draw = FALSE), 
  panel = function(...) {
    panel.levelplot(...)
    sp.points(s.sp, col = 'white', cex = 0.5, pch = 16)
  }
)


# buffer sample points slightly to add some noise
b <- terra::buffer(s, 0.5)

# check
plot(p, col = viridis(25), axes = FALSE)
plot(b, add = TRUE, border = 'white')


# original values from unconditional simulation 
.original <- extract(p, s, method = 'bilinear')$sim1

# conditional simulations, without ID column
.simulated <- extract(sim, terra::buffer(s, 1), method = 'bilinear', fun = mean)[, -1]

.rmse <- function(x, y) {
  sqrt(mean((y - x)^2, na.rm = TRUE))
}

# check distribution, all pixels
boxplot(list(original = values(p), sim = values(sim)), horizontal = TRUE, las = 1, varwidth = TRUE, boxwex = 0.5)

## RMSE is very low, close to 0 across all simulations
sapply(.simulated, function(i) {
  .rmse(i, .original)
})



### conditional simulation based on real data

# make a bounding box and assign a CRS (4326: GCS, WGS84)
a.CA <- st_bbox(
  c(xmin = -121, xmax = -120, ymin = 37, ymax = 38), 
  crs = st_crs(4326)
)

# convert bbox to sf geometry
a.CA <- st_as_sfc(a.CA)
pH_3060cm <- ISSR800.wcs(aoi = a.CA, var = 'ph_3060cm')
names(pH_3060cm) <- 'pH'

## exhaustive sampling for variogram model estimation
set.seed(101010)
s <- spatSample(pH_3060cm, size = 1000, method = 'random', as.points = TRUE)

# spatVect -> sp
s.sp <- as(s, 'Spatial')
s.sp <- s.sp[which(!is.na(s.sp$pH)), ]

# model variogram / check
v <- variogram(pH ~ x + y, s.sp)
plot(v)
m <- fit.variogram(v, vgm(psill = 0.2, model = "Sph", range = 50000, nugget = 0.04))
plot(v, m)


## new sample, much less dense, used for conditional simulation
set.seed(101010)
s <- spatSample(pH_3060cm, size = 100, method = 'random', as.points = TRUE)
s.sp <- as(s, 'Spatial')
s.sp <- s.sp[which(!is.na(s.sp$pH)), ]

# spatRast -> raster -> SPDF
xy <- raster(pH_3060cm)
xy <- as(xy, 'SpatialPixelsDataFrame')

# quick check
plot(xy)
points(s.sp, pch = 16)


## conditional simulation
set.seed(101010)
sim <- krige(
  formula = pH ~ 1, 
  s.sp, 
  xy, 
  model = m, 
  nmax = 10, 
  beta = 5.9, 
  nsim = 5
)


# SPDF -> raster stack -> spatRaster
sim <- rast(stack(sim))
crs(sim) <- 'EPSG:5070'

# combine original grid + simulated grids
z <- c(pH_3060cm, sim)

# check that values at points are identical
e <- extract(z, s[which(!is.na(s$pH)), ])
apply(e[, -1], 1, function(i) {length(unique) })


# graphical eval

png(file = 'figures/spatial-simulation-same-rmse.png', width = 1200, height = 800, res = 90)

levelplot(
  z, 
  col.regions = viridis,
  scales = list(draw = FALSE), 
  panel = function(...) {
    panel.levelplot(...)
    sp.points(s.sp, col = 'black', cex = 0.5, pch = 16)
  },
  layout = c(3,2)
)

dev.off()

### do the patterns hold up after aggregation?


# 
a <- aggregate(z, fact = 10, fun = 'mean', na.rm = TRUE)

levelplot(
  a, 
  col.regions = viridis,
  scales = list(draw = FALSE), 
  panel = function(...) {
    panel.levelplot(...)
    sp.points(s.sp, col = 'black', cex = 0.5, pch = 16)
  }
)


setwd("M:/Rscripts/IntroToRaster/data")
untar("LC81970242014109-SC20141230042441.tar.gz")
untar("LT51980241990098-SC20150107121947.tar.gz")
lc8list <- list.files(pattern = glob2rx("LC81970242014109LGN00_*.tif"), full.names = TRUE)
lc8stack <- stack(lc8list)
#just testing
lc8brick <-brick(lc8list)
writeRaster(x=lc8stack, filename = "lc8stack.grd", datatype = "INT2S")
lt5list <- list.files(pattern =glob2rx("LT51980241990098KIS00_*.tif"),full.names = TRUE)
lt5stack <-stack(lt5list)
writeRaster(x=lt5stack, filename = "lt5stack.grd", datatype = "INT2S")
e <- extent(672793, 689503, 5749586, 5770406)
lc5cropped <- crop(lt5stack, e)
lc8cropped
lt5stack

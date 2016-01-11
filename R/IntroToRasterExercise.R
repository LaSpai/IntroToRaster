#Lazaros Spaias
#11/1/2016

#set the directory
setwd("M:/Rscripts/IntroToRaster/data")

#make the tar files usable
untar("LC81970242014109-SC20141230042441.tar.gz")
untar("LT51980241990098-SC20150107121947.tar.gz")

#create landsat8 StackRaster and write it 
lc8list <- list.files(pattern = glob2rx("LC81970242014109LGN00_*.tif"), full.names = TRUE)
lc8stack <- stack(lc8list)
writeRaster(x=lc8stack, filename = "lc8stack.grd", datatype = "INT2S")

#create TM StackRaster and write it
lt5list <- list.files(pattern =glob2rx("LT51980241990098KIS00_*.tif"),full.names = TRUE)
lt5stack <-stack(lt5list)
writeRaster(x=lt5stack, filename = "lt5stack.grd", datatype = "INT2S")

#set the extent and resample
e <- extent(672793, 695503, 5749586, 5770406)
extent(lt5stack) <- e
lc8stack <- setExtent(lc8stack, e, keepres = FALSE)
lt5stackresampled <- resample(lt5stack, lc8stack, method = "bilinear", filename = "lt5resampled", overwrite = TRUE)

#find out the layer's number
names(lc8stack)
names(lt5stackresampled)

#extract cloud layer from the brick
cloud <- lc8stack[[1]]
cloudlt5 <- lt5stackresampled[[1]]

#replace clear land by NA
cloud[cloud==0] <- NA
cloudlt5[cloud==0] <- NA

#plot the  lc8 stack and the cloud mask on top of each other
plotRGB(lc8stack,2,3,4, stretch ="hist" )
plot(cloud, add = TRUE, legend = FALSE)

#plot the  TM stack and the cloud mask on top of each other
plotRGB(lt5stackresampled,2,3,4, stretch ="hist" )
plot(cloudlt5, add = TRUE, legend = FALSE)


#extract cloud mask rasterLayer
fmask <- lc8stack[[1]]
fmask5 <- lt5stackresampled[[1]]

#remove fmask layer from the landsat stack
lc8nofmask <- dropLayer(lc8stack, 1)
lt5nofmask <- dropLayer(lt5stackresampled,1)

#perform value replacement
lc8nofmask[fmask != 0] <- NA
lt5nofmask[fmask != 0] <- NA

#define a value replacement function 
cloud2NA <- function(x,y) {x[y!=0]<-NA
                           return(x)}

#create a new object since lc8nofmask has been masked
lc8nofmask_2 <- dropLayer(lc8stack, 1)
lt5nofmask_2 <-dropLayer(lt5stackresampled,1)

#apply the function on the two raster objects using overlay
lc8cloudfree <- overlay(x= lc8nofmask_2,y = fmask, fun = cloud2NA)
lt5cloudfree <- overlay(x= lt5nofmask_2,y = fmask, fun = cloud2NA)

#visualize the result
plotRGB(lc8cloudfree,4,3,2,stretch = "hist")
plotRGB(lt5cloudfree,4,3,2,stretch = "hist")

#calculate NDVI
lc8NDVI <- (lc8cloudfree[[6]]-lc8cloudfree[[5]])/ (lc8cloudfree[[6]]+lc8cloudfree[[5]])
lt5NDVI <- (lt5cloudfree[[7]]-lt5cloudfree[[6]])/ (lt5cloudfree[[7]]+lt5cloudfree[[6]])
plot(lc8NDVI)
plot(lt5NDVI)

#subtract the two NDVI rasters to show the difference of NDVI
comparison <- lc8NDVI-lt5NDVI
comparison2<- lt5NDVI-lc8NDVI
plot(comparison) 
plot(comparison2)

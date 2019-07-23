library(tidyverse)
library(R.matlab)
library(akima)
library(oce)
library(S285)

fold <- "~/data/SEA/S285/ChUMP/MAT/"
files <- list.files(fold, pattern = "*.mat")

ctd <- NULL
for (i in 1:length(files)) {
  file <- file.path(fold,files[i])
  data <- readMat(file)$cast[,,1]
  time <- mean(lubridate::as_datetime(as.vector(data$t-1)*24*60*60,origin = "0000-01-01"),na.rm=TRUE)
  ii <- sea::find_near(S285$elg$dttm,time)

  ctdadd <- as.ctd(salinity = data$S[1,], temperature = data$T[1,],
                   pressure = data$p[1,], conductivity = data$C[1,],
                   # theta = oce::swTheta(data$S[1,],data$T[1,],data$p[1,]),
                   # sigmaTheta = oce::swSigma0(data$S[1,],data$T[1,],data$p[1,]),
                   time = time,
                   longitude = S285$elg$lon[ii],
                   latitude = S285$elg$lat[ii])
  ctdadd <- oce::oceSetData(ctdadd, "theta", oce::swTheta(data$S[1,],data$T[1,],data$p[1,]))
  ctdadd <- oce::oceSetData(ctdadd, "sigmaTheta", oce::swSigma0(data$S[1,],data$T[1,],data$p[1,]))
  ctdadd <- oce::oceSetData(ctdadd, "depth",  oce::swDepth(ctdadd@data$pressure, ctdadd@metadata$latitude))


  ctdadd <- ctdTrim(ctdadd,parameters = list(pmin=2))
  ctd <- append(ctd,ctdadd)

  # create data frame version

  ctd_add2 <- tibble::tibble(dep = ctdadd@data$depth,
                            temp = ctdadd@data$temperature,
                            theta = ctdadd@data$theta,
                            sigtheta = ctdadd@data$sigmaTheta,
                            sal = ctdadd@data$salinity,
                            lon = ctdadd@metadata$longitude,
                            lat = ctdadd@metadata$latitude,
                            station = i,
                            cruise = "S285")
  if (i == 1){
    ctd2 <- ctd_add2
  } else {
    ctd2 <- dplyr::bind_rows(ctd2,ctd_add2)
  }

}

ctd2 <- mutate(ctd2, dist = oce::geodDist(lon,lat,alongPath = TRUE))
S285$chump <- ctd
S285$chump2 <- ctd2

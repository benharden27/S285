# Add extra chla fields to hydrowork

root_folder <-  file.path("~/data/SEA", cruiseID)

hydro <- sea::read_datasheet(file.path(root_folder,"SHIPDATA/S285_hydrowork.xlsm"))
S285$hydro <- dplyr::mutate(S285$hydro,
                          chla_45 = as.numeric(hydro$`Chl.a.0.45µm.(ug/l)`),
                          chla_120 = as.numeric(hydro$Chl.a.1.2µm),
                          chla_300 = as.numeric(hydro$Chl.a.3.0µm),
                          chla_800 = as.numeric(hydro$Chl.a.8.0µm))

# create size frac data frame
S285$hydro$lon[1] <- S285$hydro$lon[2]
S285$hydro$lat[1] <- S285$hydro$lat[2]
stations <- unique(S285$hydro$station)
deps <- c(0,50,100)
depran <- 5
for (i in 1:length(stations)) {

  df<- dplyr::filter(S285$hydro,station == stations[i])

  for (j in 1:length(deps)) {
    df2 <- dplyr::filter(df,z>deps[j]-depran/2 & z<deps[j]+depran/2)

    df_add <- summarize_if(df2,is.numeric,mean,na.rm = TRUE)
    df_add <- mutate(df_add, station = stations[i], dttm = df2$dttm[1])
    # df_add[ ,c(ncol(df_add)-1,ncol(df_add),1:(ncol(df_add)-2))]
    if (i == 1 & j == 1) {
      df_out <- df_add
    } else {
      df_out <- bind_rows(df_out,df_add)
    }
  }
}

S285$sizefrac <- df_out

# Add oxygen and par to ctd data

a <- S285

for (j in 1:length(a$ctd)) {
  # find possible oxygen values
  ii <- stringr::str_which(names(a$ctd[[j]]@data),"oxygen")
  mean_o2 <- colMeans(sapply(a$ctd[[j]]@data[ii], unlist),na.rm = T)
  oval <- ii[which(mean_o2 < 10)][1]

  if(is.null(a$ctd[[j]]@data$par)) {
    par = NA
  } else {
    par <- a$ctd[[j]]@data$par
  }


  station <- paste0(cruiseID,"_",stringr::str_pad(a$ctd[[j]]@metadata$station,3,pad = "0"))


  ctd_add <- tibble::tibble(dep = a$ctd[[j]]@data$depth,
                            temp = a$ctd[[j]]@data$temperature,
                            theta = a$ctd[[j]]@data$theta,
                            sigtheta = a$ctd[[j]]@data$sigmaTheta,
                            sal = a$ctd[[j]]@data$salinity,
                            fluor = a$ctd[[j]]@data$fluorescence,
                            par = par,
                            oxygen = a$ctd[[j]]@data[[oval]],
                            lon = a$ctd[[j]]@metadata$longitude,
                            lat = a$ctd[[j]]@metadata$latitude,
                            station = station,
                            cruise = "S285")
  if (j == 1){
    ctd <- ctd_add
  } else {
    ctd <- dplyr::bind_rows(ctd,ctd_add)
  }
}

S285$ctd2 <- ctd

# Add nutrient and echo intensity to neuston
S285$neuston <- dplyr::mutate(S285$neuston, station2 = stringr::str_remove(S285$neuston$station,"-NT"))
# S285$hydro <- dplyr::mutate(S285$hydro, station2 = stringr::str_remove(S285$hydro$station,"-HC"))

a <- dplyr::mutate(S285$surfsamp, station2 = paste0("S285-",stringr::str_remove(station,"(-HC.*|-SS.*)")))

S285$neuston <- dplyr::left_join(S285$neuston, select(a,station2, no3, po4),by = "station2")
S285$neuston <- dplyr::select(S285$neuston,-station2)


S285$adcp$dttm <- S285$adcp$dttm-60*60*4



ti <- sea::find_near(S285$adcp$dttm,S285$neuston$dttm_in)
window <- 24
echo <- rowMeans(S285$adcp$Idb[,1:5], na.rm = TRUE)
echo_mean <- rep(NA,length(ti))
for (i in 1:length(ti)) {
  echo_mean[i] <- mean(echo[(ti[i]-window/2):(ti[i]+window/2)], na.rm = T)
}

S285$neuston <- mutate(S285$neuston, echo = echo_mean)

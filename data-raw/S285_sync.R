cruiseID <- "S285"
NAS <- "192.168.100.158" # Seamans
# NAS <- "192.168.100.160" # Cramer

# Unmount program data
system("umount ~/data/studata")
# system("diskutil unmount ~/data/studata")

# Mount the program data file
system(paste0("mount -t smbfs //science:coriolis@", NAS, "/Program_Data ~/data/studata"))

# rsync SHIPDATA
system(paste0("rsync -av --no-r ~/data/studata/SHIPDATA/", cruiseID, "* ~/data/SEA/" ,cruiseID, "/SHIPDATA"))

# rsync Calculation sheets
system(paste0("rsync -av ~/data/studata/Calculation\\ Sheets ~/data/SEA/", cruiseID))

# rsync cnv CTD folder
system(paste0("rsync -avR ~/data/studata/./CTD/Cnv/ ~/data/SEA/", cruiseID))

# # rsync ELG event data
system(paste0("rsync -av ~/data/studata/EventData/Event60sec_059.elg ~/data/SEA/", cruiseID))

# # rsync ADCP LTA files
system(paste0("rsync -av ~/data/studata/ADCP/", cruiseID,"*.STA ~/data/SEA/", cruiseID, "/ADCP"))

# Create packaged C282 data file
S285 <- sea::package_data("~/data/SEA/S285")

# Add chump data
source("data-raw/read_chump.R")

# Add extra fields
source("data-raw/read_extras.R")

# Add the data to the package
usethis::use_data(S285,overwrite = TRUE)

# library(seacarb)
# carb(8,pHinsi(S285$hydro$pH[goodi],Tinsi = S285$hydro$temp[goodi], Tlab = S285$hydro$pH_lab_temp[goodi]),2400e-6,S = S285$hydro$sal[goodi],T = S285$hydro$temp[goodi], P = S285$hydro$z[goodi]/10)

# install the package
system("R CMD INSTALL --no-multiarch --with-keep.source ~/data/SEA/S285/S285")

# # Create ODV
# source("~/Documents/SEA/C282_OE/R/C282_ODV.R")
# system("rsync -av ~/data/SEA/C282/ODV ~/data/studata/Data/")

# # Copy cruise plots to program data
# system("rsync -av ~/Documents/SEA/C282_OE/R/C282_cruise_plots.html ~/data/studata/")

# Render the html cruise plots
rmarkdown::render("~/Documents/SEA/S285_OC/sea_component/R/S285_cruise_plots.Rmd")

system("rsync -av ~/Documents/SEA/S285_OC/sea_component/R/S285_cruise_plots.html ~/data/studata/")

devtools::build()
system("rsync -av ~/data/SEA/S285/S285_0.0.1.tar.gz ~/data/studata/")
# install.packages("~/data/SEA/S285/S285_0.0.1.tar.gz", repos = NULL)

# Unmount program data
system("umount ~/data/studata")


cruiseID <- "S285"
NAS <- "192.168.100.158" # Seamans
# NAS <- "192.168.100.160" # Cramer

# Unmount program data
system("umount ~/data/studata")

# Mount the program data file
system(paste0("mount -t smbfs //aftcabin:C0r1oLi\\$@", NAS, "/Program Data ~/data/studata"))
system(paste0("mount_smbfs //", NAS, "/ProgramData ~/data/studata"))

# rsync SHIPDATA
system(paste0("rsync -av --no-r ~/data/studata/Data/SHIPDATA/", cruiseID, "* ~/data/SEA/" ,cruiseID, "/SHIPDATA"))

# rsync Calculation sheets
system(paste0("rsync -av ~/data/studata/Data/Calculation\\ Sheets ~/data/SEA/", cruiseID))

# rsync cnv CTD folder
system(paste0("rsync -avR ~/data/studata/Data/./CTD/Cnv/ ~/data/SEA/", cruiseID))

# rsync ELG event data
system("rsync -av ~/data/studata/EventData/Event60sec_014.elg ~/data/SEA/C282")

# rsync ADCP LTA files
system("rsync -av ~/data/studata/Data/LTA/C282*.LTA ~/data/SEA/C282/ADCP")

# Create packaged C282 data file
S285 <- sea::package_data("~/data/SEA/S285")

# Add the data to the package
devtools::use_data(S285,overwrite = TRUE)

# # Create ODV
# source("~/Documents/SEA/C282_OE/R/C282_ODV.R")
# system("rsync -av ~/data/SEA/C282/ODV ~/data/studata/Data/")

# # Copy cruise plots to program data
# system("rsync -av ~/Documents/SEA/C282_OE/R/C282_cruise_plots.html ~/data/studata/")


# Unmount program data
system("umount ~/data/studata")

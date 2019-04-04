# Create datasets for SEA C282 data package

# Create packaged C282 data file
S282 <- sea::package_data("~/data/SEA/S285")

# Add the data to the package
devtools::use_data(S285,overwrite = TRUE)


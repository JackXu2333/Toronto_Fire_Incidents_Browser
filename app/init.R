#
# This file contain and loaded all the required libraries
#
#

if (!requireNamespace("shiny", quietly = TRUE))    
  install.packages("shiny")
if (!requireNamespace("sf", quietly = TRUE))    
  install.packages("sf")
if (!requireNamespace("raster", quietly = TRUE))    
  install.packages("raster")
if (!requireNamespace("dplyr", quietly = TRUE))    
  install.packages("dplyr")
if (!requireNamespace("spData", quietly = TRUE))    
  install.packages("spData")
if (!requireNamespace("tidyverse", quietly = TRUE))    
  install.packages("tidyverse")
if (!requireNamespace("lubridate", quietly = TRUE))    
  install.packages("lubridate")
if (!requireNamespace("tmap", quietly = TRUE))    
  install.packages("tmap")
if (!requireNamespace("leaflet", quietly = TRUE))    
  install.packages("leaflet")
if (!requireNamespace("ggplot2", quietly = TRUE))    
  install.packages("ggplot2")

fire_Size_Table <- c("Extinguished", "Small", "Medium", "Large")
fire_Type_Table <- c("Fire", "Explosion")
area_Origin_Table <- c("Cooking Area or Kitchen", "Trash, Rubbish Storage", "Porch or Balcony", "Engine Area (Vehicle)", "Other")

fire_Size_Choice <- seq(1:length(fire_Size_Table))
names(fire_Size_Choice) <- fire_Size_Table

fire_Type_Choice <- seq(1:length(fire_Type_Table))
names(fire_Type_Choice) <- fire_Type_Table

area_Origin_Choice <- seq(1:length(area_Origin_Table))
names(area_Origin_Choice) <- area_Origin_Table

intro <- "The purpose of this visualization is to inform the city planners and the fire department about details of fire incidents in the City of Toronto. 
More specifically, this visualization is designed to help city planners and the fire department to decide where additional fire stations should be built within the city, 
to reduce the number of fire incidents or minimize loss from such. The data that are used in the visualization is from The City of Toronto’s Open Data Portal. 
The datasets that we used included fire incidents data, fire station locations, and neighborhood profiles (Toronto Census 2016). There are two parts in the visualization: 
1) a map on the left side and 3) a scatterplot on the right side. When the website is first opened, an info (information) box will pop up and hover over the scatterplot, 
in which highlights in the visualization will be stated, and readers can close it whenever so the scatterplot would be visible again. If the readers are interested in reading 
it again, the reader can click on a small button on the top right corner of the website to open the info box again."

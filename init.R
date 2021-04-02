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

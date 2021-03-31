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
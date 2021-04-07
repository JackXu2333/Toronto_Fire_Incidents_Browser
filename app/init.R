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

intro_Text <- "Welcome to our project, “Fire Incident Browser in the City of Toronto and its Surrounding Neighborhoods”. 
We are the Fancy Thoughts Squad.] This project aims to inform the city planners and the fire department about details 
of fire incidents in the City of Toronto. More specifically, this visualization is designed to help city planners and 
the fire department to decide where additional fire stations should be built within the city, to reduce the number of fire incidents or minimize loss from such."

fire_Type_Info <- "The type of fire that was recorded by the firefighters first arrived at the scene including Fire, Explosion and No Loss Outdoor Fire."

fire_Size_Info <- paste("The size of fire that was recorded by the firefighters first arrived at the scene",
"1. Extinguished: fire was extinguished prior to arrival",
"2. Small: there was no evidence of fire from the street",
"3. Medium: fire with smoke only or flames showing from a small area",
"4. Large: flames were showing from a large area or that and explosion was involved", sep = "<br>")

origin_of_Fire_Info <-"The most common origins of fire, Other includes Bedroom, Living Room etc."

financial_Loss_Info <- "The estimated amount of dollar loss"

casualties_Info <- "Civilian casualties observed at scene, including both injured and dead"

firefighters_Info <- "Number of Firefighters responded and arrived at the scene"

time_Period_Info <- "Time stamps of fire occurrence"



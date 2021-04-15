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

scatter_X_Table <- data.frame(varible <- c("Total Incidents", "Total Fire Stations", "Population", "Land Area", "Population Density", "Total Dwellings Area Occupied", 
                                           "Average Household Size","Average Household Income", "Average Personal Income", "Percentage Person Living Alone",
                                           "Percentage Low Income Population", "Percentage Population Without Diploma"),
                              attribute <- c("Total_Incidents", "Total_Station", "Population", "Land_Area_In_Sqkm", "Population_Density_Per_Sqkm", "Dwellings_Occupied_By_Usual_Residents", 
                                             "Average_Household_Size","Average_Household_Income", "Average_Personal_Income", "Percentage_Person_Living_Alone",
                                             "Percentage_Low_Income_Base_On_Cutoffs", "Percentage_No_Certificate_Diploma"))
scatter_Y_Table <- data.frame(varible <- c("Average Response Time", "Average Casualty" ,"Average Financial Loss"),
                              attribute <- c("Average_Response_Time", "Average_Casualty" ,"Average_Financial_Loss"))

scatter_X_Choice <- seq(1:length(scatter_X_Table$varible))
names(scatter_X_Choice) <- scatter_X_Table$varible

scatter_Y_Choice <- seq(1:length(scatter_Y_Table$varible))
names(scatter_Y_Choice) <- scatter_Y_Table$varible

geo_Intro_Text <- "Welcome to our project, “Fire Incident Browser in the City of Toronto and its Surrounding Neighborhoods”. 
We are the Fancy Thoughts Squad.] This project aims to inform the city planners and the fire department about details 
of fire incidents in the City of Toronto. More specifically, this visualization is designed to help city planners and 
the fire department to decide where additional fire stations should be built within the city, to reduce the number of fire incidents or minimize loss from such.
To view the detailed data attributes of each fire incident and neighbourhoods, Please click on the Data Explorer tab on the top."

data_Intro_Text <- "Welcome to the data explorer tools for Fire Incident Browser in the City of Toronto; in this tab, you can navigate freely through the detailed
data attributes of each fire incident and neighborhoods. You may also explore the correlations between fire incidents and characteristics of the Neighborhoods! 
Such as the one shown on the scatter plot. Variables on both axes can be adjusted by clicking the gear button on the top left corner. Data used are coming from Statistics Canada
and Open Data Toronto. Please visit our Github page for more detail: https://github.com/JackXu2333/STA313_Final_Project"

data_Description_Text <- HTML(paste("Welcome to the data explorer tools for Fire Incident Browser in the City of Toronto.",
"To explore the correlations between fire incidents and characteristics of the Neighborhoods, please visit the Data Trend tab.",
"To explore the fire incident and neighborhoods data set used in this project, please use the Fire Incidents / Neighbourhood tab", sep = "<br/><br/>"))

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

Fire_Station_Checkbox_Info <- "Show fire stations on the map, click on the fire station icons to view detailed information of the station."
  
Nbh_Background_Checkbox_Info <- "Show the border line of each neighborhood on the map, as well as the fire incidents density by the land area under current filter settings,  click any points within neighborhoods to zoom in and view details regarding the neighbourhood of interest"

Independent_Varibles_Info <- paste("Select the manipulated variables that may coorlated with the fire incidents", sep = "<br>")

Dependent_Varibles_Info <-  paste("Select the responding variables that summarize the fire incidents in each neighborhoods",
                                  "1. Average Response Time, the average of the firefighters' response time (time duration from initial alarm time till arrival time)", 
                                  "2. Average Casualty, the average number of casualties" ,
                                  "3. Average Financial Loss, the average losses from each incidents in Canadian dollar", sep = "<br>")
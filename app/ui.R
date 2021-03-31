source("../init.R")
library(shiny)
library(shinyBS)
library(dplyr)
library(leaflet)
library(ggplot2)

# Define UI for application that draws a histogram
shinyUI(
    
    navbarPage("Fancy Thoughts", id="nav",
    
        tabPanel("Interactive map",
            div(class="outer",
                
            # Include our custom CSS 
            tags$head(includeCSS("style.css")),
            
            leafletOutput("map", width = "100%", height = "100%"),
        
            # Sidebars with viewing inputs
            absolutePanel(id = "controls", class = "panel panel-default",
                top = 20, left = "auto", right = 20, bottom = "auto",
                width = 330, height = "auto",
                
                h2("City of Toronto fire incidents browser"),
                
                # slider for selecting type of fire
                selectInput("Fire_Type",
                                "Select fire type",
                                choices = list("Fire" = 1, "Explosion" = 2, 
                                               "Outdoor Fire" = 3, "All" = 4), selected = 4),
                bsTooltip(id = "Fire_Type", title = "Type of fire recorded by the firefighters", 
                             placement = "bottom", trigger = "hover", options = NULL),

                    
                # slider for selecting the size of fire
                selectInput("Fire_Size",
                                       "Select fire size",
                                       choices = list("Extinguished" = 1, "Small" = 2, 
                                                      "Medium" = 3, "Large" = 4, "All" = 5),selected = 5),
                bsTooltip(id = "Fire_Size", title = "Size of fire when firefighters arrrived at scene", 
                              placement = "bottom", trigger = "hover", options = NULL),

                    
                # slider for selecting the orgin of fire
                selectInput("Area_Origin",
                                "Select estimated orgin of fire",
                                choices = list("Cooking" = 1, "Engine" = 2, 
                                               "Trash Storage" = 3, "Parch or Balcony" = 4,
                                               "Others" = 5, "All" = 6), selected = 6),
                bsTooltip(id = "Area_Origin", title = "The estimated orgin of fire", 
                              placement = "bottom", trigger = "hover", options = NULL),
                    
                # slider for selecting financial loss
                shinyWidgets::sliderTextInput("Financial_Loss",
                                "Select range of financial loss",
                                choices=c(0, 10, 100, 1000, 10000,100000, 1000000),
                                selected = c(10,10000), grid = T),
                bsTooltip(id = "Financial_Loss", title = "The estimated amount of financial loss", 
                              placement = "bottom", trigger = "hover", options = NULL),
                    
                # slider for selecting number of casualties
                sliderInput("Casualties",
                                "Number of civillian injured or dead",
                                min = 0, max = 15,
                                value = 0),
                bsTooltip(id = "Casualties", title = "Number of civillian injured or dead", 
                              placement = "bottom", trigger = "hover", options = NULL),
                    
                # slider for selecting number of personnel
                shinyWidgets::sliderTextInput("Num_Personnel",
                                "Number of firefighters arrivaled at the scene",
                                choices=c(0, 5, 10, 20, 35, 50, 100),
                                selected = c(0,10), grid = T),
                bsTooltip(id = "Num_Personnel", title = "Number of firefighters arrivaled at the scene", 
                              placement = "bottom", trigger = "hover", options = NULL),
                
                # Date input
                dateRangeInput("Time","Select time period"),
                bsTooltip(id = "Time", title = "Incidents that occurred during this period of time", 
                              placement = "bottom", trigger = "hover", options = NULL)
        
                ),
            
            # Sidebars with scatter plot
            absolutePanel(id = "scatterplot", class = "panel panel-default",
                          fixed = TRUE, draggable = TRUE, top = "auto", left = 20, right = "auto", bottom = 20,
                          width = "auto", height = "auto",
                          
                          plotOutput("scatterplot", height = 300,  width = 450))
            )
        ),
        tabPanel("Data explorer", id="nav")
    )
)

source("init.R")
library(shiny)
library(shinyWidgets)
library(shinyBS)
library(dplyr)
library(leaflet)
library(ggplot2)

# Define UI for application that draws a histogram
shinyUI(
    
    navbarPage(div(img(id = "logo", src="logo.png"), "Fancy Thoughts"), id="nav", 
    
        tabPanel("Interactive map",
            div(class="outer",
                
            # Include our custom CSS 
            tags$head(includeCSS("style.css")),
            
            leafletOutput("map", width = "100%", height = "100%"),
        
            # Sidebars with viewing inputs
            absolutePanel(id = "controls", class = "panel panel-default",
                top = 20, left = "auto", right = 20, bottom = "auto",
                width = 330, height = "auto",
                
                h2("City of Toronto fire incidents browser", bsButton("s0",  label = "", icon = icon("info"), size = "extra-small") ),
                
                # slider for selecting type of fire
                pickerInput("Fire_Type",
                            label = h4("Fire type ", bsButton("s1", class = "info",  label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                choices = fire_Type_Choice, multiple = TRUE, selected = 1,
                                options = list(`actions-box` = TRUE)),
                bsPopover(id = "s1", title = "Fire Type", placement = "left", content =  fire_Type_Info),

                    
                # slider for selecting the size of fire
                pickerInput("Fire_Size",
                            label = h4("Fire size", bsButton("s2", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                            choices = fire_Size_Choice, multiple = TRUE, selected = 1,
                            options = list(`actions-box` = TRUE)),
                bsPopover(id = "s2", title = "Fire Size",placement = "left",content =  fire_Size_Info),

                    
                # slider for selecting the origin of fire
                pickerInput("Area_Origin",
                            label = h4("Orgin of fire", bsButton("s3", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                            choices = area_Origin_Choice, multiple = TRUE, selected = 1,
                            options = list(`actions-box` = TRUE)),
                bsPopover(id = "s3", title = "Orgin of Fire", placement = "top",content =  origin_of_Fire_Info),

                # slider for selecting financial loss
                sliderTextInput("Financial_Loss",
                                label = h4("Financial loss", bsButton("s4", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                choices=c(0, 10, 100, 1000, 10000,100000, 1000000),
                                selected = c(0,10000), grid = T),
                bsPopover(id = "s4", title = "Financial Loss",placement = "top", content =  financial_Loss_Info),
                    
                # slider for selecting number of casualties
                sliderInput("Casualties",
                            label = h4("Casualties", bsButton("s5", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                min = 0, max = 15,
                                value = 0),
                bsPopover(id = "s5", title = "Casualties", placement = "top",content =  casualties_Info),
                    
                # slider for selecting number of personnel
                shinyWidgets::sliderTextInput("Num_Personnel",
                                label = h4("Number of firefighters at scene", bsButton("s6", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                choices=c(0, 5, 10, 20, 35, 50, 100),
                                selected = c(0,10), grid = T),
                bsPopover(id = "s6", title = "Number of firefighters at scene", placement = "left",content =  firefighters_Info),
                
                # Date input
                dateRangeInput("Time",
                               label = h4("Time period", bsButton("s7", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                               "2011-01-01", "2019-07-01"),
                bsPopover(id = "s7", title = "Time period", placement = "top", content =  time_Period_Info),
                
                # Refresh
                actionButton("Refresh", "Click to refresh"),
                actionButton("Zoom_Out", "Return to full view")
        
                ),
            
            # Sidebars with scatter plot
            absolutePanel(id = "scatterplot", class = "panel panel-default",
                          fixed = TRUE, top = "auto", left = 20, right = "auto", bottom = 20,
                          width = "auto", height = "auto",
                          
                          plotOutput("scatterplot", height = 300,  width = 450))
            )
        ),
        tabPanel("Data explorer", id="nav")
    )
)

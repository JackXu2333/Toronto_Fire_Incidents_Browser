source("init.R")
library(shiny)
library(shinyWidgets)
library(shinyBS)
library(dplyr)
library(leaflet)
library(ggplot2)
library(DT)

mapSideBar <- absolutePanel(id = "controls", class = "panel panel-default", draggable = FALSE,
                         top = 20, left = "auto", right = 20, bottom = "auto",
                         width = 330, height = "auto",
                         
                         h2("City of Toronto Fire Incidents Browser", bsButton("s0",  label = "", icon = icon("info"), style = "info", size = "extra-small") ),
                         
                         # Add progress bar
                         progressBar(id = "DataCompletion", value = 0, total = 15496, display_pct = TRUE, title = h4("Total Incidents Shown")),
                         
                         # slider for selecting the size of fire
                         pickerInput("Fire_Size", 
                                     label = h4("Fire Size", bsButton("s2", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                     choices = fire_Size_Choice, multiple = TRUE, selected = fire_Size_Choice,
                                     options = list(`actions-box` = TRUE)),
                         bsPopover(id = "s2", title = "Fire Size",placement = "left",content =  fire_Size_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         # slider for selecting the origin of fire
                         pickerInput("Area_Origin",
                                     label = h4("Origin of Fire", bsButton("s3", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                     choices = area_Origin_Choice, multiple = TRUE, selected = seq(1,4),
                                     options = list(`actions-box` = TRUE)),
                         bsPopover(id = "s3", title = "Orgin of Fire", placement = "top",content =  origin_of_Fire_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         # slider for selecting financial loss
                         sliderTextInput("Financial_Loss",
                                         label = h4("Financial Loss", bsButton("s4", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                         choices=c(0, 10, 100, 1000, 10000,100000, 1000000),
                                         selected = c(0,10000), grid = T),
                         bsPopover(id = "s4", title = "Financial Loss",placement = "top", content =  financial_Loss_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         # slider for selecting number of casualties
                         sliderInput("Casualties",
                                     label = h4("Casualties", bsButton("s5", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                     min = 0, max = 15,
                                     value = c(0, 5)),
                         bsPopover(id = "s5", title = "Casualties", placement = "top",content =  casualties_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         # slider for selecting number of personnel
                         shinyWidgets::sliderTextInput("Num_Personnel",
                                                       label = h4("Number of Firefighters at Scene", bsButton("s6", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                                       choices=c(0, 5, 10, 20, 35, 50, 100),
                                                       selected = c(0,10), grid = T),
                         bsPopover(id = "s6", title = "Number of firefighters at scene", placement = "left",content =  firefighters_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         dateRangeInput("Time",
                                        label = h4("Time Period", bsButton("s7", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                        "2011-01-01", "2019-07-01"),
                         bsPopover(id = "s7", title = "Time period", placement = "top", content =  time_Period_Info),
                         
                         # Checkbox
                         checkboxInput(
                             inputId = "Fire_Station_Checkbox", 
                             label = p("Show Fire Stations", bsButton("s8", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small"))
                         ),
                         bsPopover(id = "s8", title = "Show Fire Stations", placement = "top", content =  Fire_Station_Checkbox_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         checkboxInput(
                             inputId = "Nbh_Background_Checkbox", 
                             label = p("Show Neighbourhoods", bsButton("s9", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                             value = T
                         ),
                         bsPopover(id = "s9", title = "Show Neighbourhoods", placement = "top", content =  Nbh_Background_Checkbox_Info),
                         
                         div(style = "margin-top:-15px"),
                         
                         # Refresh
                         actionButton("Refresh", "Load Settings", class = "btn-primary"),
                         actionButton("Zoom_Out", "Reset View")
                         
)

# Define UI for application that draws a histogram
shinyUI(
  
  fluidPage(
    tags$head(HTML("<title>Toronto Fire Incidents Browser</title> <link rel='icon' type='image/gif/png' href='logo.png'>")),
  
    navbarPage(div(img(id = "logo", src="logo.png"), "Fancy Thoughts"), id="nav", 
               
               tabPanel("Interactive Map",
                        div(class="outer",
                            
                            # Include our custom CSS 
                            tags$head(includeCSS("style.css")),
                            
                            leafletOutput("map", width = "100%", height = "100%"),
    
                            mapSideBar
                            
                            # Sidebars with scatter plot
                            #absolutePanel(id = "scatterplot", class = "panel panel-default",
                            #              fixed = TRUE, top = "auto", left = 20, right = "auto", bottom = 20,
                            #              width = "auto", height = "auto",
                            #              
                            #              plotOutput("scatterplot", height = 300,  width = 450))
                        )
               ),
               tabPanel("Data Explorer", id="nav",
                        
                        sidebarLayout(
                      
                            sidebarPanel(width = 4,id = "controls", class = "panel panel-default", fluid = F,
                                         
                                         h2("City of Toronto Fire Incidents Data Explorer", bsButton("x0",  label = "", icon = icon("info"), style = "info", size = "extra-small") ),
                                         br(),
                                         data_Description_Text
                                ),
                            
                            mainPanel(
                                
                              tabsetPanel(
                                
                                tabPanel("Data Trend", 
                                         br(),
                                         dropdownButton(
                                           
                                           tags$h3("List of Inputs"),
                                           
                                           selectInput("ScatterX", 
                                                       label = h4("Independent varibles (X)", bsButton("x1", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                                       choices = scatter_X_Choice, selected = 7),
                                           bsPopover(id = "x1", title = "Independent Varibles",placement = "left",content =  Independent_Varibles_Info),
                                           
                                           div(style = "margin-top:-15px"),
                                           
                                           selectInput("ScatterY", 
                                                       label = h4("Dependent varibles (Y)", bsButton("x2", class = "info", label = "", icon = icon("question"), style = "info", size = "extra-small")),
                                                       choices = scatter_Y_Choice, selected = 1),
                                           bsPopover(id = "x2", title = "Dependent Varibles",placement = "left",content =  Dependent_Varibles_Info),
                                           
                                           checkboxInput(
                                             inputId = "show_MA_Checkbox", label = p("Show Moving Average"), value = F
                                           ),
                                           
                                           div(style = "margin-top:-15px"),
                                           
                                           checkboxInput(
                                             inputId = "show_LM_Checkbox", label = p("Show Linear Model"), value = T
                                           ),
                                           
                                           div(style = "margin-top:-15px"),
                                           
                                           checkboxInput(
                                             inputId = "x_log_Checkbox", label = p("Show X Axis in Log Scale"), value = F
                                           ),
                                           
                                           circle = F, status = "info",
                                           icon = icon("gear"), width = "300px",
                                           
                                           tooltip = tooltipOptions(title = "Click to change inputs!")
                                         ),
                                         plotOutput("scatterplot"),
                                         div(style = "margin-top:15px"),
                                         htmlOutput("linear_model")
                                         ),
                                tabPanel("Neighbourhood",dataTableOutput("neighbourhoodDatatable")),
                                tabPanel("Fire Incidents",dataTableOutput("incidentsDatatable"))
                                
                              )
                                
                            )
                            
                        )
                        
               )
    )
  )
)

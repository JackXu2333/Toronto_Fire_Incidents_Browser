# Read fire Incidents file
fire_Incidents <- readRDS("data/Trimmed_Fire_Incidents.Rds")
fire_Stations <- readRDS("data/Trimmed_Fire_Station.Rds")
neighbourhood_Shape <- readRDS("data/neighbourhoods_info.Rds")

shinyServer(function(input, output) {
    
    # Set global variable for plotting scatter plot / showing details
    global_varible <- reactiveValues(fire_incidents_input = fire_Incidents, current_neibourhood = "", current_shape_event = 0)
    
    # the modal dialog where the user can enter the query details.
    query_modal <- modalDialog(
        title = "Important message",
        helpText(intro_Text),
        easyClose = F
    )
    
    # Show the model on start up ...
    showModal(query_modal)
    
    observeEvent(input$s0, {
        showModal(query_modal)
    })
    
    # Create the map
    output$map <- renderLeaflet({
        
        # Set color factor
        colorData <- fire_Incidents$Neighborhood
        pal <- colorFactor("BuGn", colorData)
        
        leaflet(fire_Stations) %>% addProviderTiles("CartoDB.Positron") %>% 
            setView(lng = -79.24, lat = 43.74, zoom = 11)  
    })
    
    refreshMap <- function(){
        
        Fire_Type <- input$Fire_Type %>% as.integer()
        Fire_Size <- input$Fire_Size %>% as.integer()
        Area_Origin <- input$Area_Origin %>% as.integer()
        Financial_Loss <- input$Financial_Loss
        Casualties <- input$Casualties
        Num_Personnel <- input$Num_Personnel
        Time <- input$Time
        
        # filter continues variables
        fire_Incidents_Filtered <- fire_Incidents %>% 
            filter(Estimated_Dollar_Loss >= Financial_Loss[1] & Estimated_Dollar_Loss <= Financial_Loss[2]) %>% 
            filter(Civilian_Casualties <= Casualties) %>% 
            filter(Number_of_responding_personnel >= Num_Personnel[1] & Number_of_responding_personnel <= Num_Personnel[2]) %>%
            filter(TFS_Alarm_Date >= Time[1] & TFS_Alarm_Date <= Time[2])%>% 
            filter(Fire_Type_Case %in% fire_Type_Table[Fire_Type])%>% 
            filter(Fire_Size_Case %in% fire_Size_Table[Fire_Size])%>% 
            filter(Area_Orgin_Case %in% area_Origin_Table[Area_Origin])
        
        # Add current filtering to the gv
        global_varible$fire_incidents_input <- fire_Incidents_Filtered
        
        # Coloring
        colorData <- fire_Incidents_Filtered$Fire_Size_Case
        pal <- colorFactor("YlOrRd", colorData)
        colorData_nbh <- neighbourhood_Shape$num_incidents
        pal_nbh <- colorNumeric(c("#D7D8C9", "#57523E"), colorData_nbh)
        
        log_Estimated <- log(fire_Incidents_Filtered$Estimated_Dollar_Loss) * 0.8
        
        leafletProxy("map", data = fire_Incidents_Filtered) %>% clearShapes() %>% clearMarkers() %>%
            addPolygons(data = neighbourhood_Shape, 
                        stroke = F, color = "Grey", weight = 1 ,opacity = .2, 
                        layerId=~AREA_ID,
                        fillOpacity = 0.3, fillColor=pal_nbh(colorData_nbh)) %>%
            addMarkers(fire_Stations$Longitude, fire_Stations$Latitude, layerId=~fire_Stations$ID,
                       icon=makeIcon("icons/svg/008-firefighter helmet.svg", iconWidth = 25, iconHeight = 25)) %>%
            addCircleMarkers(~Longitude, ~Latitude, radius=log_Estimated, layerId=~X_id,
                             stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData))
    }
    
    # This observer is responsible for maintaining the circles and legend,
    # according to the variables the user has chosen to map to color and size.
    observeEvent(input$Refresh,{
        
        refreshMap()
         
    })
    
    # Reset the view of the map
    observeEvent(input$Zoom_Out, {
        
        # Reset view
        leafletProxy("map") %>% 
            setView(lng = -79.24, lat = 43.74, zoom = 11) 
        
        refreshMap()
        
        # Reset neighborhood
        global_varible$current_neibourhood <- ""
    })
    
    # Plot the scatter plot for given location
    time_incident_plot <- function(current_data){
        
    }
    
    # Draw the scatter plot
    output$scatterplot <- renderPlot({
        
        # Get data
        fire_Incidents_Filtered <- global_varible$fire_incidents_input
        neibourhood_Filtered <- global_varible$current_neibourhood
        
        # Check if any neighborhood is clicked
        if (neibourhood_Filtered != ""){
            fire_Incidents_Filtered <- fire_Incidents_Filtered %>% 
                filter(Neighborhood == neibourhood_Filtered)}
        
        # Group by date
        fire_Incidents_Filtered <- fire_Incidents_Filtered %>%
            group_by(TFS_Alarm_Month) %>%
            summarise(count = n(), .groups = 'drop') 
        
        # Plot the scatter plot
        plot_title <- "Number of incidents by time in"
        plot_title <- paste(plot_title, ifelse(neibourhood_Filtered == "", "Toronto", neibourhood_Filtered))
        
        ggplot(fire_Incidents_Filtered, aes(x=TFS_Alarm_Month, y=count)) + 
            geom_point()+ geom_smooth(stat = 'smooth',method = 'loess', formula = y ~ x)+ ggtitle(plot_title)+
            xlab("Time")+ ylab("Number of fire Incidents")+
            theme(plot.title = element_text(color="Black", size=14, face="bold"))
        
    })
    
    # Show a popup at the given location
    showNeibourhoodPopup <- function(neigbourhoodSelected, id, lat, lng) { 
        
        content <- as.character(tagList(
            tags$h4("Neibourhood:", neigbourhoodSelected$AREA_NAME),
            tags$strong(HTML(sprintf("Location: %s, %s",lat, lng))), tags$br(),
            sprintf("Current population: %s",lat), tags$br(),
            sprintf("Total Area: %s sqft",lat), tags$br(),
            sprintf("Population density: %s sqft",lat), tags$br(),
            sprintf("Number of fire stations: %s ",lat), tags$br(),
            sprintf("Total of incidents since 2011: %s",lat)
        ))
        
        # set popups
        leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
    
    }
    
    # Show a popup at the given location
    showPointPopup <- function(id, lat, lng) { 
        
        if (id > 1350000) {
            content <- as.character(tagList(
                tags$h4("Fire incident NO.", as.integer(id)),
                tags$strong(HTML(sprintf("Location: %s, %s",
                                         lat, lng
                ))), tags$br()
            ))
        } else {
            content <- as.character(tagList(
                tags$h4("Fire station NO.", as.integer(id)),
                tags$strong(HTML(sprintf("Location: %s, %s",
                                         lat, lng
                ))), tags$br()
            ))
        }
        
        # set popups
        leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
        
    }
    
    # When map is clicked, show a popup with city info
    observe({
        leafletProxy("map") %>% clearPopups()
        event <- input$map_shape_click
        if (is.null(event))
            return()
        
        neigbourhoodSelected <- neighbourhood_Shape[which(neighbourhood_Shape$AREA_ID == event$id),]
        
        # Add current filtering to the gv
        global_varible$current_neibourhood <- neigbourhoodSelected$AREA_NAME
        
        neigbourhoodSelected$AREA_ID <- neigbourhoodSelected$AREA_ID * 100
            
        #Find binding box and change location
        #Add highlight
        neigbourhoodSelectedBBox <- neigbourhoodSelected$geometry %>% sf::st_bbox()
        leafletProxy("map") %>% flyToBounds(as.numeric(neigbourhoodSelectedBBox$xmin), as.numeric(neigbourhoodSelectedBBox$ymin), 
                                            as.numeric(neigbourhoodSelectedBBox$xmax), as.numeric(neigbourhoodSelectedBBox$ymax))
            
        isolate({
            showNeibourhoodPopup(neigbourhoodSelected, event$id, event$lat, event$lng)
        })
            
    })
    
    # When shape is clicked, show a popup with location info
    observe({
        leafletProxy("map") %>% clearPopups()
        event <- input$map_marker_click
        if (is.null(event) )
            return()

        global_varible$current_incidents <- event$id
        
        
        isolate({
            showPointPopup(event$id, event$lat, event$lng)
        })
        
    })
    

})

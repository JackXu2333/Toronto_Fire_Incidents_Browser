# Read fire Incidents file
fire_Incidents <- readRDS("data/Trimmed_Fire_Incidents.Rds")
fire_Stations <- readRDS("data/Trimmed_Fire_Station.Rds")
neighbourhood_Shape <- readRDS("data/neighbourhoods_info.Rds")


shinyServer(function(input, output) {
    
    # Set global variable for plotting scatter plot / showing details
    global_varible <- reactiveValues(fire_incidents_input = fire_Incidents, current_neibourhood = "", current_incidents = 0)
    
    # Create the map
    output$map <- renderLeaflet({
        
        # Set color factor
        colorData <- fire_Incidents$Neighborhood
        pal <- colorFactor("BuGn", colorData)
        
        leaflet(fire_Stations) %>% addProviderTiles("CartoDB.Positron") %>% 
            setView(lng = -79.24, lat = 43.74, zoom = 11)  
    })
    
    # This observer is responsible for maintaining the circles and legend,
    # according to the variables the user has chosen to map to color and size.
    observeEvent(input$Refresh,{
        
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
        pal_nbh <- colorNumeric("Greys", colorData_nbh)
        
        log_Estimated <- log(fire_Incidents_Filtered$Estimated_Dollar_Loss) * 10
        
        leafletProxy("map", data = fire_Incidents_Filtered) %>% clearShapes() %>%
            addPolygons(data = neighbourhood_Shape, 
                        stroke = T, color = "Grey", weight = 1 ,opacity = .2, 
                        layerId=~AREA_ID,
                        fillOpacity = 0.2, fillColor=pal_nbh(colorData_nbh)) %>%
            addCircles(~Longitude, ~Latitude, radius=log_Estimated, layerId=~X_id,
                       stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>% 
            addCircles(fire_Stations$Longitude, fire_Stations$Latitude, radius=100,
                       stroke = F,layerId=fire_Stations$ID,
                       fillOpacity = 0.2, fillColor = "blue")
    })
    
    # Reset the view of the map
    observeEvent(input$Zoom_Out, {
        
        # Reset view
        leafletProxy("map") %>% 
            setView(lng = -79.24, lat = 43.74, zoom = 11)  
        
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
            summarise(count = n()) 
        
        # Plot the scatter plot
        ggplot(fire_Incidents_Filtered, aes(x=TFS_Alarm_Month, y=count)) + 
                geom_point()+ geom_smooth()+ ggtitle("Demo Scatterplot")+theme(
                    plot.title = element_text(color="red", size=14, face="bold"))
        
    })
    
    # Show a popup at the given location
    showZipcodePopup <- function(zipcode, lat, lng) { 
        
        # set popups
        leafletProxy("map") %>% addPopups(lng, lat, "Popups", layerId = zipcode)
    
    }
    
    # When map is clicked, show a popup with city info
    observe({
        leafletProxy("map") %>% clearPopups()
        event <- input$map_shape_click
        if (is.null(event))
            return()
        
        # If neighborhood is clicked
        if (event$id > 2480000){ 
            neigbourhoodSelected <- neighbourhood_Shape[which(neighbourhood_Shape$AREA_ID == event$id),]
            # Add current filtering to the gv
            global_varible$current_neibourhood <- neigbourhoodSelected$AREA_NAME
            
            #Find binding box and change location
            neigbourhoodSelected <- neigbourhoodSelected$geometry %>% sf::st_bbox()
            leafletProxy("map") %>% flyToBounds(as.numeric(neigbourhoodSelected$xmin), as.numeric(neigbourhoodSelected$ymin), 
                                                as.numeric(neigbourhoodSelected$xmax), as.numeric(neigbourhoodSelected$ymax))
            
            # If fire incidents is clicked
        } else if (event$id > 1350000) {
            # Add current filtering to the gv
            global_varible$current_incidents <- event$id
            
            # If fire stations is clicked
        } else {
            # Add current filtering to the gv
            global_varible$current_incidents <- event$id
        }
        
        isolate({
            showZipcodePopup(event$id, event$lat, event$lng)
        })
    })

    

})

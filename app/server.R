# Read fire Incidents file
fire_Incidents <- readRDS("data/Trimmed_Fire_Incidents.Rds")
fire_Stations <- readRDS("data/Trimmed_Fire_Station.Rds")
neighbourhood_Shape <- readRDS("data/neighbourhoods_info.Rds")
neighbourhood_Shape_Info <- neighbourhood_Shape %>% as.data.frame()

shinyServer(function(input, output, session) {
    
    # Set global variable for plotting scatter plot / showing details
    global_varible <- reactiveValues(fire_incidents_input = fire_Incidents, current_neighborhoods = "", current_shape_event = 0)
    
    # the modal dialog where the user can enter the query details.
    geo_modal <- modalDialog(
        title = "Welcome to City of Toronto Fire Incidents Browser",
        p(geo_Intro_Text), br(),
        img(src = "map-instructions.png", width = "100%", height = "auto"),
        easyClose = F,
        size = "l"
    )
    
    data_modal <- modalDialog(
        title = "Welcome to City of Toronto Fire Incidents Data Explorer",
        p(data_Intro_Text),
        easyClose = F,
        size = "l"
    )
    
    # Show the model on start up ...
    showModal(geo_modal)
    
    observeEvent(input$s0, {
        showModal(geo_modal)
    })
    
    observeEvent(input$x0, {
        showModal(data_modal)
    })
    
    # Create the map
    output$map <- renderLeaflet({
        
        # Set color factor
        colorData <- fire_Incidents$Neighborhood
        pal <- colorFactor("BuGn", colorData)
        
        leaflet(fire_Stations) %>% addProviderTiles("CartoDB.Positron") %>% 
            fitBounds(lng1 = -79.63926, lat1 = 43.58100, lng2 = -79.11527, lat2 = 43.85546)  
    })
    
    refreshMap <- function(){
        
        Fire_Size <- input$Fire_Size %>% as.integer()
        Area_Origin <- input$Area_Origin %>% as.integer()
        Financial_Loss <- input$Financial_Loss
        Casualties <- input$Casualties
        Num_Personnel <- input$Num_Personnel
        Time <- input$Time
        
        # filter continues variables
        fire_Incidents_Filtered <- fire_Incidents %>% 
            filter(Estimated_Dollar_Loss >= Financial_Loss[1] & Estimated_Dollar_Loss <= Financial_Loss[2]) %>% 
            filter(Civilian_Casualties >= Casualties[1] & Civilian_Casualties <= Casualties[2]) %>% 
            filter(Number_of_responding_personnel >= Num_Personnel[1] & Number_of_responding_personnel <= Num_Personnel[2]) %>%
            filter(TFS_Alarm_Date >= Time[1] & TFS_Alarm_Date <= Time[2])%>% 
            filter(Fire_Size_Case %in% fire_Size_Table[Fire_Size])%>% 
            filter(Area_Orgin_Case %in% area_Origin_Table[Area_Origin])
        
        # Update progression bar
        updateProgressBar(session = session, id = "DataCompletion", value = nrow(fire_Incidents_Filtered), total = 15496)
        
        # Add current filtering to the gv
        global_varible$fire_incidents_input <- fire_Incidents_Filtered
        
        # Remove elements
        leafletProxy("map") %>% clearShapes() %>% clearMarkers()
        
        # Add neighborhood
        if (input$Nbh_Background_Checkbox){
            
            # Calculate current incidents
            current_Incidents <- fire_Incidents_Filtered %>% group_by(Neighborhood) %>% summarise(Current_Incidents = n(), .groups = 'drop')
            neighbourhood_Shape_current <- left_join(neighbourhood_Shape, current_Incidents, by = c("Area_Name" = "Neighborhood"))
            if (sum(is.na(neighbourhood_Shape_current$Current_Incidents)) != 0) {
            neighbourhood_Shape_current[which(is.na(neighbourhood_Shape_current$Current_Incidents)),]$Current_Incidents <- 0}
            
            colorData_nbh <- neighbourhood_Shape_current$Current_Incidents / neighbourhood_Shape_current$Land_Area_In_Sqkm
            pal_nbh <- colorNumeric(c("white", "black"), colorData_nbh)
            
            leafletProxy("map") %>% clearShapes() %>%
                addPolygons(data = neighbourhood_Shape_current, stroke = T, color = "Grey", weight = 1 ,opacity = .5, 
                            layerId=~AREA_ID, fillOpacity = 0.5, fillColor=pal_nbh(colorData_nbh)) %>%
                addLegend("topleft", pal = pal_nbh, colorData_nbh, 
                          layerId = "NbhLegend", title="Fire Incidents Density")
        } 
        
        
        # Coloring
        colorData <- fire_Incidents_Filtered$Fire_Size_Case
        pal <- colorFactor("YlOrRd", colorData)
        
        leafletProxy("map", data = fire_Incidents_Filtered) %>%
            addCircleMarkers(~Longitude, ~Latitude, radius=4, layerId=~X_id,
                             stroke=FALSE, fillOpacity=1, fillColor=pal(colorData)) %>%
            addLegend("topleft", pal = pal, colorData, 
                      layerId = "IncidentsLegend", title="Fire Size")
        
        
        # Add fire stations
        if (input$Fire_Station_Checkbox){
            
            html_legend <- "<img src='fire-station.png', width = 25px, height = 25px> Fire Stations"
            
            leafletProxy("map", data = fire_Stations) %>% 
                addMarkers(~Longitude, ~Latitude, layerId=~ID,
                           icon=makeIcon("www/fire-station.svg", iconWidth = 25, iconHeight = 25)) %>%
                addControl(html = html_legend, position = "topleft", layerId = "FireStationLegend")
        }
        
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
            flyToBounds(lng1 = -79.63926, lat1 = 43.58100, lng2 = -79.11527, lat2 = 43.85546)
        
        refreshMap()
        
        # Reset neighborhood
        global_varible$current_neighborhoods <- ""
    })
    
    # Plot the scatter plot for given location
    time_incident_plot <- function(current_data){
        
    }
    
    # Show a popup at the given location
    showNeighborhoodPopup <- function(neighborhoodSelected, id, lat, lng) { 
        
        content <- as.character(tagList(
            tags$h4("Neighborhood:", neighborhoodSelected$Area_Name),
            sprintf("Current Population: %s", neighborhoodSelected$Population), tags$br(),
            sprintf("Total Area: %s Square km", neighborhoodSelected$Land_Area_In_Sqkm), tags$br(),
            sprintf("Population Density: %s square km", neighborhoodSelected$Population_Density_Per_Sqkm), tags$br(),
            sprintf("Number of Fire Stations: %s ", neighborhoodSelected$Total_Station), tags$br(),
            sprintf("Total of Incidents (2011-2019): %s", neighborhoodSelected$Total_Incidents)
        ))
        
        # set popups
        leafletProxy("map") %>% addPopups(lng, lat, content, layerId = id)
    
    }
    
    # Show a popup at the given location
    showPointPopup <- function(id, lat, lng) { 
        
        if (id > 1350000) {
            
            currentIncident <- fire_Incidents %>% filter(X_id == id)
            
            content <- as.character(tagList(
                tags$h4("Fire incident NO.", as.integer(id)),
                sprintf("Intersection: %s",currentIncident$Intersection), tags$br(),
                sprintf("Fire Size: %s", currentIncident$Fire_Size_Case), tags$br(),
                sprintf("Original of Fire: %s", currentIncident$Area_Orgin_Case), tags$br(),
                sprintf("Financial Loss: %s", currentIncident$Estimated_Dollar_Loss), tags$br(),
                sprintf("Casualties: %s", currentIncident$Civilian_Casualties), tags$br(),
                sprintf("Number of Firefighters on Site: %s", currentIncident$Number_of_responding_personnel), tags$br(),
                sprintf("Date of Incident: %s", currentIncident$TFS_Alarm_Date)
            ))
        } else {
            
            currentStation <- fire_Stations %>% filter(ID == id)
            
            content <- as.character(tagList(
                tags$h4(currentStation$NAME),
                tags$strong(HTML(sprintf("Located Neighborhood: %s", currentStation$Neighborhood))), tags$br(),
                sprintf("Address: %s", currentStation$ADDRESS)
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
        
        neighborhoodSelected <- neighbourhood_Shape[which(neighbourhood_Shape$AREA_ID == event$id),]
        
        # Add current filtering to the gv
        global_varible$current_neighborhoods <- neighborhoodSelected$Area_Name
            
        #Find binding box and change location
        #Add highlight
        neighborhoodSelectedBBox <- neighborhoodSelected$geometry %>% sf::st_bbox()
        leafletProxy("map") %>% flyToBounds(as.numeric(neighborhoodSelectedBBox$xmin), as.numeric(neighborhoodSelectedBBox$ymin), 
                                            as.numeric(neighborhoodSelectedBBox$xmax), as.numeric(neighborhoodSelectedBBox$ymax))
            
        isolate({
            showNeighborhoodPopup(neighborhoodSelected, event$id, event$lat, event$lng)
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
    
    #-------------------------------------DashBoard---------------------------------------------------
    
    
    # Draw data table
    output$neighbourhoodDatatable <- renderDataTable({
        
        neighbourhood_Shape_Info[,-which(names(neighbourhood_Shape) %in%
                                        c("geometry", "AREA_LONG_CODE", "Shape__Area", "Shape__Length", "OBJECTID", "Area_Short_Code", "AREA_ID", "AREA_DESC"))]

        
    })
    
    # Draw fire incidents data
    output$incidentsDatatable <- renderDataTable({
        
        fire_Incidents_data <- fire_Incidents %>% as.data.frame()
        fire_Incidents_data[,-which(names(fire_Incidents) %in%
                                   c("Latitude", "Longitude", "geometry", "Fire_Type_Case", "Status_of_Fire_On_Arrival", "Final_Incident_Type", "Area_of_Origin", "TFS_Alarm_Year", "TFS_Alarm_Month"))]
        
    })
    
    # Draw scatterplots according to the x-y
    output$scatterplot <- renderPlot({
        
        vx.select <- input$ScatterX
        vy.select <- input$ScatterY
        
        vx.value <- scatter_X_Table[vx.select,1]
        vy.value <- scatter_Y_Table[vy.select,1]
        
        vx.attr <- scatter_X_Table[vx.select,2]
        vy.attr <- scatter_Y_Table[vy.select,2]
        
        ifMA <- input$show_MA_Checkbox
        ifLM <- input$show_LM_Checkbox
        ifLog <- input$x_log_Checkbox
        
        plot_title <- sprintf("%s vs %s by Neighborhoods", vx.value, vy.value)
        
        output <- ggplot(neighbourhood_Shape, aes_string(x=vx.attr, y=vy.attr)) + geom_point() + 
            ggtitle(plot_title) + labs(x =vx.value, y = vy.value)+
            theme(plot.title = element_text(color="Black", size=14, face="bold"))+ 
            scale_color_manual(name="Legend", values=c("blue", "red"))
        
        if (ifMA){output <- output + geom_smooth(stat = 'smooth',method = 'loess', formula = y ~ x, aes(colour="Moving Avg"))}
        if (ifLM){output <- output + geom_smooth(method = 'lm', formula = y ~ x, aes(colour="Linear")) }
        
        if (ifLog){output <- output + scale_x_log10()}
        
        output
        
    })
    
    output$linear_model <- renderUI({ 
        
        vx.select <- input$ScatterX
        vy.select <- input$ScatterY
        
        vx.value <- scatter_X_Table[vx.select,1]
        vy.value <- scatter_Y_Table[vy.select,1]
        
        vx.attr <- scatter_X_Table[vx.select,2]
        vy.attr <- scatter_Y_Table[vy.select,2]
        
        fit <- lm(neighbourhood_Shape_Info[, vy.attr] ~ neighbourhood_Shape_Info[, vx.attr])
        fit_coefficients <- summary(fit)$coefficients
        ci95 <- c(fit_coefficients[2] - 1.96 * fit_coefficients[4], fit_coefficients[2] + 1.96 * fit_coefficients[4])
        
        if (!input$show_LM_Checkbox){
            ""
        } else if (ci95[1] < 0 & ci95[2] > 0) {
            HTML(paste(tags$b(sprintf("The linear model shows there is no significant correlation between %s and %s", vy.value, vx.value)), 
                       sprintf("* This is based on the observation that the coefficient's 95%% confident interval is (%.5f, %.5f).
                               This means that in 95%% of the time, the value coefficient will fell in the range that contains 0,
                               it is very likely that the coefficient is 0 and thus the correlation does not exist.", ci95[1], ci95[2]),
                       sep = "<br/>")
            )
        } else {
            HTML(paste("The linear model fitted above is", 
                       tags$b(sprintf("%s = %.2f * %s + %.2f ", vy.value, fit_coefficients[2], vx.value, fit_coefficients[1])), 
                       sprintf("in which the p-value for coefficient is < %.2f, and intersect is < %.2f", fit_coefficients[8], fit_coefficients[7]),
                       sprintf("* The model shows that for increase in 1 unit of %s, %s will change by %.2f", vx.value, vy.value, fit_coefficients[2]),
                       sep = "<br/>")
            )
        }
        
    })
    
    # Draw the scatter plot
    #output$scatterplot <- renderPlot({
    #    
    #    # Get data
    #    fire_Incidents_Filtered <- global_varible$fire_incidents_input
    #    neighborhoods_Filtered <- global_varible$current_neighborhoods
    #    
    #    # Check if any neighborhood is clicked
    #    if (neighborhoods_Filtered != ""){
    #        fire_Incidents_Filtered <- fire_Incidents_Filtered %>% 
    #            filter(Neighborhood == neighborhoods_Filtered)}
    #    
    #    # Group by date
    #    fire_Incidents_Filtered <- fire_Incidents_Filtered %>%
    #        group_by(TFS_Alarm_Month) %>%
    #        summarise(count = n(), .groups = 'drop') 
    #    
    #    # Plot the scatter plot
    #    plot_title <- "Number of incidents by time in"
    #    plot_title <- paste(plot_title, ifelse(neighborhoods_Filtered == "", "Toronto", neighborhoods_Filtered))
    #    
    #    ggplot(fire_Incidents_Filtered, aes(x=TFS_Alarm_Month, y=count)) + 
    #        geom_point()+ geom_smooth(stat = 'smooth',method = 'loess', formula = y ~ x)+ ggtitle(plot_title)+
    #        xlab("Time")+ ylab("Number of fire Incidents")+
    #        theme(plot.title = element_text(color="Black", size=14, face="bold"))
    #    
    #})

})

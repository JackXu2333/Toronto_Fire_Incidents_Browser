# Read fire Incidents file
fireIncidents <- readRDS("../data/Fire_Incidents.Rds")

shinyServer(function(input, output) {
    
    # Create the map
    output$map <- renderLeaflet({
        leaflet(fireIncidents[1:10,]) %>% addProviderTiles("CartoDB.Positron") %>% 
            addCircles(~Longitude, ~Latitude, radius=10, layerId=~X_id,
                                       stroke=T, fillOpacity=0.4) %>%
            setView(lng = -79.24, lat = 43.74, zoom = 10)
    })
    
    output$scatterplot <- renderPlot({
        ggplot(mtcars, aes(x=wt, y=mpg)) + 
            geom_point()+ geom_smooth()+ ggtitle("Demo Scatterplot")+theme(
                plot.title = element_text(color="black", size=14, face="bold")
            )
    })

    

})

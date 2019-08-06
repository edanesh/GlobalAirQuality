#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

# prerequisites 
library(bigrquery)
library(tidyverse)
library(leaflet)
library(shiny)

json_path <- paste(getwd(), "/big-sunup-248507-4dd62ea09179", sep="")
bq_auth(email = "e.danesh@gmail.com", path = json_path)
# accessing database in BigQuery

project <- "big-sunup-248507"
query_CO <- "SELECT location, value, latitude, longitude FROM `bigquery-public-data.openaq.global_air_quality` WHERE (pollutant like 'co' AND value > 0)"


# Define server logic required 

shinyServer(function(input, output) {
        
        data <- reactive({
                input$go
                tb_CO <- bq_project_query(project, query_CO)
                data_CO <- bq_table_download(tb_CO)
                sites <- data_CO %>%
                        mutate(names=location, index=value, lat=latitude, lng=longitude) %>%
                        select(names, index, lat, lng)
                sites
        })
        
        getColor <- function(sites) {
                sapply(sites$index, function(index) {
                        if(index <= 359) {
                                "green"
                        } else if(index <= 600) {
                                "orange"
                        } else {
                                "red"
                        } })
        }
        icons <- awesomeIcons(
                icon = 'ios-close',
                iconColor = 'black',
                library = 'ion',
                markerColor = getColor(isolate(data()))
        )
        
        output$COmap <- renderLeaflet({
                data()  %>% 
                        leaflet() %>% 
                        addTiles() %>% 
                        addAwesomeMarkers(icon=icons, label=~names, clusterOptions = markerClusterOptions(iconCreateFunction=JS("function (cluster) {    
    var childCount = cluster.getChildCount();  
    if (childCount < 100) {  
      c = 'rgba(128, 128, 128, 0.5);'
    } else if (childCount < 1000) {  
      c = 'rgba(128, 128, 128, 0.5);'  
    } else { 
      c = 'rgba(128, 128, 128, 0.5);'  
    }    
    return new L.DivIcon({ html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(40, 40) });

  }"), maxClusterRadius = 20)) %>% addLegend(title = "CO Level", labels = c("High (>1000 ug/m3)", "Medium (500-1000 ug/m3)", "Low (<500 ug/m3)"), colors = c("red", "orange", "green"))
                
        })
        
})

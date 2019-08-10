#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(googleAuthR)
library(bigQueryR)
library(tidyverse)
library(leaflet)

# set the scopes required
options(
        googleAuthR.scopes.selected = c(
                "https://www.googleapis.com/auth/bigquery",
                "https://www.googleapis.com/auth/cloud-platform"
        )
)

# you may also set the client id and secret here as well
options(googleAuthR.client_id = "822733051602-009ejjdpvlaiho0iqqsp0ss9qras42h2.apps.googleusercontent.com",
        googleAuthR.client_secret = "pFK-TGh7pAsEsuhYc8kSfQc6")

bqr_auth(".httr-oauth")

project <- "big-sunup-248507"
query_CO <-
        "SELECT location, value, latitude, longitude
FROM `bigquery-public-data.openaq.global_air_quality`
WHERE (pollutant like 'co' AND value > 0)"

server <- function(input, output, session) {
        # leaflet
        
        data <- reactive({
                input$go
                data_CO <-
                        bqr_query(project,
                                  "sample",
                                  query_CO,
                                  useLegacySql = FALSE)
                
                
                sites <- data_CO %>%
                        mutate(
                                names = location,
                                index = value,
                                lat = latitude,
                                lng = longitude
                        ) %>%
                        select(names, index, lat, lng)
                sites
        })
        
        
        getColor <- function(sites) {
                sapply(sites$index, function(index) {
                        if (index <= 359) {
                                "green"
                        } else if (index <= 600) {
                                "orange"
                        } else {
                                "red"
                        }
                })
        }
        
        
        output$COmap <- renderLeaflet({
                input$go
                
                data()  %>%
                        leaflet() %>%
                        addTiles() %>%
                        addCircleMarkers(
                                label =  ~ names,
                                fillColor = getColor(isolate(data())),
                                fillOpacity = 0.5,
                                radius = 6,
                                stroke = FALSE
                                
                        ) %>% addLegend(
                                title = "CO Level",
                                labels = c(
                                        "High (>1000 ug/m3)",
                                        "Medium (500-1000 ug/m3)",
                                        "Low (<500 ug/m3)"
                                ),
                                colors = c("red", "orange", "green")
                        )
                
        })
        
        output$timestamp <- renderText({
                input$go
                as.character(Sys.time())
        })
}
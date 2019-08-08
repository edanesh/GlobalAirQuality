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

#options(httr_oob_default = TRUE)

project <- "big-sunup-248507"
query_CO <-
        "SELECT location, value, latitude, longitude
FROM `bigquery-public-data.openaq.global_air_quality`
WHERE (pollutant like 'co' AND value > 0)"


custom_cluster <- "function (cluster) {
var childCount = cluster.getChildCount();
if (childCount < 100) {
c = 'rgba(128, 128, 128, 0.5);'
} else if (childCount < 1000) {
c = 'rgba(128, 128, 128, 0.5);'
} else {
c = 'rgba(128, 128, 128, 0.5);'
}
return new L.DivIcon({ html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(40, 40) });
}"


server <- function(input, output, session) {
        # leaflet
        observeEvent(eventExpr = input[["submit_loc"]],
                     handlerExpr = {
                             data <- reactive({
                                     input$go
                                     
                                     # with bigqueryr
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
                                             addAwesomeMarkers(
                                                     icon = icons,
                                                     label =  ~ names,
                                                     clusterOptions = markerClusterOptions(
                                                             iconCreateFunction = JS(custom_cluster),
                                                             maxClusterRadius = 20
                                                     )
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
                     })
}
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
#library(shinyjs)
#library(bigrquery)
library(bigQueryR)
library(tidyverse)
library(leaflet)
# library(googleID)

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


# custom_cluster <- "function (cluster) {
# var childCount = cluster.getChildCount();
# if (childCount < 100) {
# c = 'rgba(128, 128, 128, 0.5);'
# } else if (childCount < 1000) {
# c = 'rgba(128, 128, 128, 0.5);'
# } else {
# c = 'rgba(128, 128, 128, 0.5);'
# }
# return new L.DivIcon({ html: '<div style=\"background-color:'+c+'\"><span>' + childCount + '</span></div>', className: 'marker-cluster', iconSize: new L.Point(40, 40) });
# }"


server <- function(input, output, session) {
        # ## Global variables needed throughout the app
        # rv <- reactiveValues(login = FALSE)
        #
        # ## Authentication
        # accessToken <- callModule(
        #         googleAuth,
        #         "gauth_login",
        #         login_class = "btn btn-primary",
        #         logout_class = "btn btn-primary"
        # )
        # userDetails <- reactive({
        #         validate(need(accessToken(), "not logged in"))
        #         rv$login <- TRUE
        #         with_shiny(get_user_info, shiny_access_token = accessToken())
        # })
        #
        # ## Display user's Google display name after successful login
        # output$display_username <- renderText({
        #         validate(need(userDetails(), "getting user details"))
        #         userDetails()$displayName
        # })
        #
        # ## Workaround to avoid shinyaps.io URL problems
        # observe({
        #         if (rv$login) {
        #                 shinyjs::onclick(
        #                         "gauth_login-googleAuthUi",
        #                         shinyjs::runjs(
        #                                 "window.location.href = 'https://edanesh.shinyapps.io/testApp/';"
        #                         )
        #                 )
        #         }
        # })
        #
        
        #bqr_auth()
        
        # leaflet
        observeEvent(eventExpr = input[["submit_loc"]],
                     handlerExpr = {
                             data <- reactive({
                                     input$go
                                     
                                     # with bigrquery
                                     # tb_CO <-
                                     #         bq_project_query(project, query_CO)
                                     # data_CO <-
                                     #         bq_table_download(tb_CO)
                                     
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
                             
                             # icons <- awesomeIcons(
                             #         icon = 'circle',
                             #         iconColor = 'black',
                             #         library = 'ion',
                             #         markerColor = getColor(isolate(data()))
                             # )
                             
                             output$COmap <- renderLeaflet({
                                     data()  %>%
                                             leaflet() %>%
                                             addTiles() %>%
                                             addCircleMarkers(
                                                     #icon = icons,
                                                     label =  ~ names,
                                                     
                                                     fillColor = getColor(isolate(data())),
                                                     fillOpacity = 0.5,
                                                     radius = 5,
                                                     stroke = FALSE
                                                     # clusterOptions = markerClusterOptions(
                                                     #         iconCreateFunction = JS(custom_cluster),
                                                     #         maxClusterRadius = 20
                                                     # )
                                                     
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
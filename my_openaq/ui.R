#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)


ui <- navbarPage(
        title = "openAQ",
        windowTitle = "openAQ CO level map",
        
        tabPanel(
                "Description",
                
                mainPanel(
                        br(),
                        "Here, I have used the OpenAQ air quality database in Google Cloud Platform [1] to visualise pollution levels around the world.",
                        br(),
                        "OpenAQ is an open-source project to surface live, real-time air quality data from around the world. Their “mission is to enable previously impossible science, impact policy and empower the public to fight air pollution.” The data includes air quality measurements from 5490 locations in 47 countries.",
                        br(),
                        "Scientists, researchers, developers, and citizens can use this data to understand the quality of air near them currently. The dataset only includes the most current measurement available for the location (no historical data).",
                        br()
                )
        ),
        
        tabPanel(
                "CO Map",
                actionButton("go", "refresh"),
                mainPanel(
                        "last updated at:",
                        textOutput("timestamp"),
                        leafletOutput("COmap", height = 400)
                )
        ),
        
        tabPanel(
                "References",
                br(),
                h5("[1] Link to openAQ BigQuery database"),
                a(
                        "https://console.cloud.google.com/marketplace/details/openaq/real-time-air-quality?filter=solution-type:dataset&q=air%20quality&id=2e51036c-7370-4637-b87f-a001b591b991"
                )
        ),
        
        # hides warning/msgs in the shiny app (?)
        tags$style(
                type = "text/css",
                ".shiny-output-error { visibility: hidden; }",
                ".shiny-output-error:before { visibility: hidden; }"
        )
)

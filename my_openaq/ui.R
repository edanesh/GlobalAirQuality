#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
#library(googleAuthR)
#library(shinyjs)
library(leaflet)


ui <- navbarPage(
        title = "openAQ",
        windowTitle = "openAQ CO level map",
        
        tabPanel(
                "Tab 1"
                #useShinyjs(),
                # sidebarLayout(sidebarPanel(
                #         p("Welcome!"),
                #         googleAuthUI("gauth_login")
                # ),
                #mainPanel(textOutput("display_username"))
        ),
        
        tabPanel(
                "Tab 2",
                actionButton("go", "refresh"),
                actionButton(inputId = "submit_loc",
                             label = "Submit"),
                mainPanel(leafletOutput("COmap", height = 600))
        ),
        
        # hides warning/msgs in the shiny app (?)
        tags$style(type="text/css",
                   ".shiny-output-error { visibility: hidden; }",
                   ".shiny-output-error:before { visibility: hidden; }"
        )
)

#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

suppressWarnings(library(shiny))
suppressWarnings(library(markdown))
shinyUI(navbarPage("Coursera Data Science Specialization",
        tabPanel("shinyTextApp",
                    HTML("<strong>Joe Yadush</strong>"),
                    br(),
                    HTML("<strong>Date: 6 January 2018</strong>"),
                    br(),
                    HTML("<strong>Please see ReadMe Tab for more information</strong>"),
                    # Sidebar
                    sidebarLayout(
                            sidebarPanel(
                                    textInput("inputString", "Enter Text",value = ""),
                                    br()
                            ),
                            mainPanel(
                                    h2("Prediction"),
                                    verbatimTextOutput("prediction"),
                                    textOutput('text')
                            )
                    )
                    
           ),
           tabPanel("ReadMe",
                    mainPanel(
                            includeMarkdown("CapstoneReadme.md")
                    )
           )
)
)

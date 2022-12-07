#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(shinythemes)

introduction_page <-tabPanel(
  "Introduction",
  fluidPage(
    includeMarkdown("intro.Rmd")
  )
)

analysis_page <- tabPanel(
  "Analysis", 
  titlePanel("Understanding the Behavior of Youth on Social Media"), 
  sidebarLayout(
    sidebarPanel(uiOutput("selectTime"), uiOutput("selectGHG")), 
    mainPanel(plotlyOutput("graph"))
    )
  )

ui <- navbarPage(
  theme = shinytheme("journal"), 
  "A5",
  introduction_page, 
  analysis_page
)
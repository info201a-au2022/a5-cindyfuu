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
library(markdown)
source("app_server.R")
introduction_page <-tabPanel(
  "Introduction",
  fluidPage(
    includeMarkdown("intro.Rmd")
  )
)

analysis_page <- tabPanel(
  "Analysis", 
  titlePanel("Analyzing Countries Performance on Environmental Measures"), 
  sidebarLayout(
    sidebarPanel(uiOutput("selectTime"), 
                 uiOutput("selectGHG"), 
                 print("Looking at the graph, we can conclude that most points cluster 
                  around the bottom left corner. In general, roughly around two-thirds of countries 
                       worldwide emit greenhouse gas below average. However, as time proceeded from 1990 to 
                       2018, we can see that more and more points move further right and up. This means that
                       as we are increasing the GDP per capita in the past 30 years, the side effect is the 
                       increase of greenhouse gas emissions due to the activities that made profits. 
                       Besides, this graph gives us a general understanding of the environmental measures, 
                       economic prosperity, and well-being of some countries. Countries that cluster around 
                       the bottom right corner are environmentally friendly. They produce fewer greenhouse 
                       gas emissions and still manage to keep their economy prosperous. This group often 
                       includes Norway and Switzerland. On the opposite, countries cluster around the top 
                       right are those that are less environmentally friendly. These countries 
                       have great economies but the cost of it in terms of environmental protection is high. 
                       Countries like Qatar and Kuwait are some representatives in this cattegory. Countries
                       that are clustered in the top left corner produce relatively high greenhouse gas but 
                       low GDP. Countries at the bottom left corners produce low greenhouse gas emissions, but 
                       these countries often are poorly developed with a stagnant economy. Some countries like 
                       Afghanistan and Rwanda can be poorly developed, which result in low greenhouse gas emission.")), 
  mainPanel(plotlyOutput("graph")))
  )

ui <- navbarPage(
  theme = shinytheme("journal"), 
  "A5",
  introduction_page, 
  analysis_page
)
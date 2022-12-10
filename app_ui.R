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
  h2("Analyzing Which Countries Have Achieved Environmental Sustainability Using Greenhouse Gas Emission Per Capita and GDP Per Capita "),
  p("Greenhouse gas is gas in the atmosphere that traps heat and results in an increase in global temperature over time. It includes water vapor, carbon dioxide, methane, nitrous oxide, etc. The enormous amount of greenhouse gas increased in the atmosphere has been a critical factor resulting in many catastrophic atmospheric events. Therefore, regulating the emission of greenhouse gas has been one of the top priorities for countries worldwide. "),
  p("Although countries should decrease greenhouse gas emissions as much as possible, other factors such as economic prosperity and the well-being of citizens are equally important to achieve environmental sustainability.  According to the three pillars of sustainability,  it is important for a country to find a balance between environmental viability, social equity, and environmental protection in environmental measures. Therefore, on this website, I used population(people), GDP (dollars), and greenhouse gas per capita (tons/capita)to analyze the performance of countries’ environmental measures. Because of the lack of data, we will only use GDP per capita, which is a great index to analyze the economic prosperity and the well-being of people in the country. Particularly, we can use this interactive visualization to find out which countries have found environmental sustainability, having low GHG per capita and high GDP per capita."), 
  h2("Greenhouse Gas Emission Per Capita in 2019 (Most Recent Year in Dataset)"), 
  print("In 2019, the average greenhouse gas emissions across all countries is "),
  textOutput("avg", container = span), 
  print(" tons per capita. The highest emission is "), 
  textOutput("max", container = span), 
  print(" tons per capita from "), 
  textOutput("maxCoun", container = span), 
  print(".The lowest emission is "), 
  textOutput("min", container = span), 
  print(" tons per capita from "), 
  textOutput("minCoun", container = span), 
  print(". The greenhouse emission has decreased by "), 
  textOutput("diff", container = span), 
  print(" tons per capita compared to the emissions last 29 years.")
)

analysis_page <- tabPanel(
  "Analysis", 
  titlePanel("Analyzing Countries Performance on Environmental Measures"), 
  sidebarLayout(
    sidebarPanel(uiOutput("selectTime"), 
                 uiOutput("selectGHG")),
  mainPanel(
    plotlyOutput("graph"), 
    p("Looking at the graph, we can conclude that most points cluster 
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
          Afghanistan and Rwanda are poorly developed, which result in low greenhouse gas emission."), 
    p("I included this chart above because it can show us how countries perform on gdp per capita 
      and greenhouse gas per capita and help us understand if they are environmentally sustainible. It reveals
      crucial information about countries each year and guide us to countries which 
      are environmentall sustainable in terms of environmental protection and economy. We can therefore
      find out what they did well in the past years and learn from them. ")
    )
  )
)

ui <- navbarPage(
  theme = shinytheme("journal"), 
  "A5",
  introduction_page, 
  analysis_page
)
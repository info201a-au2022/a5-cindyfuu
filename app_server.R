#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)
library(dplyr)
library(plotly)

# wrangle data
data <- read.csv("owid-co2-data.csv") 
 
data <- data %>% mutate(gdp_per_capita = gdp/population) %>%
  select(country, year, gdp_per_capita, ghg_per_capita, total_ghg) 
data <- na.omit(data) 

above <- data %>% 
  filter(ghg_per_capita > 4.79) %>% 
  mutate(Groups = "Above the GHG per capita of the world(4.79 tons/person")
data <- data %>% left_join(above) 
data[is.na(data)] = "Below the GHG per capita of the world(4.79 tons/person)"

server <- function(input, output) {
  
  #selecttghg
  output$selectGHG <- renderUI(return({
    minV = min(data$ghg_per_capita, na.rm = T)
    maxV = max(data$ghg_per_capita, na.rm = T)
    sliderInput("ghg", 
                label = h3("Select countries that has a green house gas emission in a particular range"), 
                min = minV, 
                max = maxV, 
                value = c(minV, maxV))
  }))
  
  #select time
  output$selectTime <- renderUI(return({
    sliderInput("time", 
                label = h3("Choose to a time you wish to view"), 
                min = min(data$year),
                max = max(data$year),
                value = 2000, 
                step = 1, 
                width = "100%")
  }))
  
  sData <- reactive({
    req(input$time)
    req(input$ghg) 
    
    time <- input$time
    time <- strtoi(time)
    ghg <- input$ghg
    points <- data %>% 
      filter(time == year, ghg_per_capita >= ghg[1], ghg_per_capita <= ghg[2])
  })
  
  #graph
  output$graph <- renderPlotly(return({
    
    plotPoints <- ggplot(sData()) + 
      geom_point(mapping = aes(x = gdp_per_capita, y = ghg_per_capita, color = Groups, stat = country)) + 
      labs(x = input$time, 
           y = nrow(sData()))
    ggplotly(plotPoints)
  }))
}

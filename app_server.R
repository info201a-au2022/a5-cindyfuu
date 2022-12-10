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

data <- read.csv("owid-co2-data.csv") 

# calculate several values for introduction
values <- data %>% select(ghg_per_capita, year) %>%
  group_by(year) %>%
  filter(year > 1989, year < 2020) %>%
  summarise(
    average = mean(ghg_per_capita, na.rm = TRUE), 
    maxValue = max(ghg_per_capita, na.rm = TRUE), 
    minValue= min(ghg_per_capita, na.rm = TRUE)
    )
top <- values$average[1]
bottom <- tail(values$average, n =1)
values <- values %>%
  filter(year == 2019) %>% 
  mutate(change_through_29_years = bottom - top) 
maxCoun <- data %>%
  filter(ghg_per_capita == values$maxValue) %>%
  pull(country)
minCoun <- data %>%
  filter(ghg_per_capita == values$minValue) %>%
  pull(country)

server <- function(input, output) {
  output$avg <- renderText({round(values$average, 2)})
  output$max <- renderText({round(values$maxValue, 2)})
  output$min <- renderText({round(values$minValue, 2)})
  output$diff <- renderText({round(values$change_through_29_years, 2)})
  output$maxCoun <- renderText({maxCoun})
  output$minCoun <- renderText({minCoun})
  
  average_ghg <- data %>%
    group_by(year) %>%
    summarise(
      average = mean(ghg_per_capita, na.rm = TRUE)) %>% 
    na.omit() 
    
  data <- data %>% mutate(gdp_per_capita = gdp/population) %>%
    select(country, year, gdp_per_capita, ghg_per_capita, total_ghg) 
  data <- na.omit(data) 
  
  
  #selecttghg
  output$selectGHG <- renderUI(return({
    minV = floor(min(data$ghg_per_capita, na.rm = T))
    maxV = ceiling(max(data$ghg_per_capita, na.rm = T))
    sliderInput("ghg", 
                label = h3("Select a range of green house gas emission to explore details of graph"), 
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
                width = "100%", 
                sep = "")
  }))
  
  # return a dataset
  sData <- reactive({
    req(input$time)
    req(input$ghg) 
    
    time <- input$time
    time <- strtoi(time)
    ghg <- input$ghg
    
    average <- average_ghg %>% 
      filter(year == time) %>%
      pull(average)
    above <- data %>% 
      filter(ghg_per_capita > average) %>% 
      mutate(Groups = paste0("Above the average GHG per capita <br> across countries(", round(average, 2)," tons/person)"))
    data <- data %>% left_join(above) 
    data[is.na(data)] = paste0("Below the average GHG per capita <br> across countries(", round(average, 2)," tons/person)")
    
    points <- data %>% 
      filter(time == year, ghg_per_capita >= ghg[1], ghg_per_capita <= ghg[2])
    return(points)
  })
  
  #graph
  output$graph <- renderPlotly(return({
    time <- input$time
    average <- average_ghg %>% 
      filter(year == time) %>%
      pull(average)
    num1 <- sData() %>% filter(ghg_per_capita > average) %>% count()
    num2 <- sData() %>% filter(ghg_per_capita <= average) %>% count()
    plotPoints <- ggplot(sData()) + 
      geom_point(mapping = aes(stat = country, x = gdp_per_capita, y = ghg_per_capita, color = Groups)) + 
      labs(x = "GDP Per Capita(dollars per capita)", 
           y = "GHG Per Capita(tons per capita)", 
           title = paste0("GHG over GDP for Countries in ", input$time," (Red Group N=", num1,", Blue Group N=", num2,")"))
    ggplotly(plotPoints)
  }))
}

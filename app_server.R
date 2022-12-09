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
# what to comment
# wrangle dat
data <- read.csv("owid-co2-data.csv") 

  values <- data %>% select(ghg_per_capita, year) %>%
  group_by(year) %>%
  summarise(
    average = mean(ghg_per_capita, na.rm = TRUE), 
    maxValue = max(ghg_per_capita, na.rm = TRUE), 
    minValue= min(ghg_per_capita, na.rm = TRUE)
    ) %>% na.omit() 
top <- values$average[1]
bottom <- tail(values$average, n =1)
values <- values %>%
  mutate(change_through_29_years = bottom - top, 
                 maxValue_2019 = tail(values$maxValue, n = 1), 
                 minValue_2019 = tail(values$minValue, n = 1), 
                 average_2019 = tail(values$average, n = 1),
         maxC_2019 = select(filter(data, year == 2019, ghg_per_capita == maxValue_2019), country), 
         minC_2019 = select(filter(data, year == 2019, ghg_per_capita == minValue_2019), country)) %>%
  select(average_2019, maxValue_2019, minValue_2019, maxC_2019, minC_2019, change_through_29_years) %>%
  head(1)


server <- function(input, output) {
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
                width = "100%", 
                sep = "")
  }))
  
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
           title = paste0("GHG over GDP for Countries in ", input$time," (Red Group = ", num1,"N, Blue Group = ", num2,"N)"))
    ggplotly(plotPoints)
  }))
}

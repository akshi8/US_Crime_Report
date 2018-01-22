## US Crime Report
## Author: Akshi Chaudhary



## Required libraries

library(shiny)
library(colourpicker)
library(dplyr)
library(ggplot2)
library(magrittr)
library(leaflet)
library(readr)
library(shinythemes)
library(shinydashboard)
library(gapminder)
library(scales)
library(tidyr)
library(stringr)
library(htmltools)



## import data

city_info <- read_csv('./data/city_info.csv')
state_list <- sort(append(unique(city_info$state),"ALL"))
city_list <- sort(append(unique(city_info$real_name),"ALL"))
city_comparison <- sort(unique(city_info$real_name))


## define user interface

shinyUI <- (
  
  navbarPage( title = "US Crime Report",
              
              
              theme = shinytheme("united"),
              
              
              
              tabPanel("Intro",
                       includeMarkdown("tutorial.md"),
                       # imageOutput("crime.png")
                       hr()
              ),
              
              # "US Crime Report",
              tabPanel("Map",
                       
                       fluidRow( sidebarPanel( width = 4,
                                               helpText("Use + / - to Zoom-in or Zoom-out on map\n Drag the map to adjust to scale\n"),
                                               helpText(""),
                                               helpText("Choose the crime to display on the map"),
                                               selectInput("crimeInput", "Type of Violent crime",
                                                           choices = c( "Homicide", "Rape","Robbery","Aggravated Assault", "All")),
                                               helpText("Crimes since 1995"),
                                               sliderInput("yearInput", 
                                                           label = "Year",
                                                           min = 1995, max = 2015, value = 2007,step=1,animate=FALSE),
                                               uiOutput("stateControls"),
                                               helpText("Checkbox to see crime rates normalised by \n population"),
                                               checkboxInput("relCheckbox", "Show crime relative to Population", value = FALSE),
                                               selectInput("stateInput", "Show by State",
                                                           choices = state_list)
                       ),
                       mainPanel(leafletOutput("map1", height = 750))
                       )
                       
                       
              ),
              
              ## Code for the table tab.
              
              tabPanel( "Trends",
                        fluidRow(sidebarPanel(width = 4,
                                              helpText("Choose the cities to compare crime rates"),
                                              
                                              selectInput("cityInput1", "City 1",
                                                          choices = city_comparison, selected = "San Francisco"),
                                              
                                              selectInput("cityInput2", "City 2", choices = city_comparison, selected = "New York"),

                                              
                                              sliderInput("yearInput2", 
                                                          label = "Year",
                                                          min = 1995, max = 2015, value = c(1975, 2015),step=1,animate=FALSE),
                                              
                                              helpText("Note the crime numbers shown are per 100k people \nin each city")
                        ),
                        
                        mainPanel(
                          
                          fluidRow(
                            splitLayout(cellWidths = c("50%"), plotOutput("distPlot1"),plotOutput("distPlot2"))
                          )
                          
                          
                        )
                        
                        
                        )
                        
                        
                        
              ),
              tabPanel( "Data",
                        fluidRow(sidebarPanel(width = 4,
                                              helpText("Choose the cities to compare raw stats"),
                                              
                                              selectInput("cityInput12", "City 1",
                                                          choices = city_comparison, selected = "San Francisco"),
                                              
                                              selectInput("cityInput22", "City 2", choices = city_comparison, selected = "New York"),
                                              
                                              
                                              sliderInput("yearInput22", 
                                                          label = "Year",
                                                          min = 1995, max = 2015, value = c(1975, 2015),step=1,animate=FALSE),
                                              helpText("Note the crime numbers shown are per 100k people \nin each city")
                        ),
                        
                        mainPanel(
                          
                          
                          fluidRow(
                            tableOutput("table1"),
                            tableOutput("table2")
                          )
                          
                        )
                        
                        
                        )
                        
                        
                        
              )
  )              
) 


## Define server details

##Data wrangling

crime_data <- read_csv('./data/crime_dataset.csv')
city_info <- read_csv('./data/city_info.csv')
city_info$lat <- as.numeric(city_info$lat)
city_info$long <- as.numeric(city_info$long)
crime_types <- data_frame(crime_type= c("homs_sum","rape_sum","rob_sum","agg_ass_sum","violent_crime"),
                          type = c("Homicide","Rape","Robbery","Aggravated Assault","All"))
crime_df <- crime_data %>% 
  gather(crime_type,quantity,5:9) %>% 
  select(ORI,year,total_pop,crime_type,quantity) %>% 
  inner_join(crime_types) %>% 
  select(-crime_type) %>% 
  inner_join(city_info,by=c("ORI"="code")) %>% 
  select(-department_name,-search_name) %>% 
  mutate(quantity_rel = quantity / total_pop * 100000) %>% 
  filter(real_name != "National")


shinyServer <- (function(input, output) {
  # Define server logic required to make the map.
  
  output$map1 <- renderLeaflet({
    test <- crime_df %>% 
      filter(year == input$yearInput,type == input$crimeInput)
    if(input$stateInput != "ALL"){
      test <- test %>% filter(state==input$stateInput)
    }
    if(input$relCheckbox == TRUE){
      test <- test %>% mutate(quantity = quantity_rel)
    }
    rule <- 25/max(test$quantity,na.rm=TRUE)
    leaflet(data=test) %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>% 
      addTiles() %>%
      addCircleMarkers(~long, 
                       ~lat,
                       popup = ~paste("<b>",real_name,"</b>",
                                      "</br>",year,
                                      "</br><b>Type:</b>",type,
                                      "</br><b>Quantity:</b>",round(quantity)),
                       label = ~as.character(real_name),
                       radius = ~(quantity * rule),
                       stroke = FALSE, 
                       color = 'green',
                       fillOpacity = 0.5) 
  })
  
  
  comparison <- crime_df %>% 
    group_by(real_name,year,type) %>% 
    summarize(total=sum(quantity_rel))
  
  output$distPlot1 <- renderPlot({
    comparison <- comparison %>% 
      filter(year >= input$yearInput2[1],
             year <= input$yearInput2[2],
             real_name == input$cityInput1)
    
    {
      ggplot(comparison %>% filter(real_name == input$cityInput1))+
        geom_line(aes(x=year,y=total, color = type),size=1,alpha=0.7) + geom_point(aes(x=year,y=total)) +
        scale_x_continuous("Year") + scale_colour_brewer(palette = "Set1") +
        scale_y_continuous("# Crimes",limits = c(0,3000))+
        ggtitle(paste("Crime Statistics for",input$cityInput1,"between :",input$yearInput2[1],"-",input$yearInput2[2]))+
        theme_bw()+
        theme(legend.position = "bottom") + labs(color = "")
      }
  })
  
  output$distPlot2 <- renderPlot({
    comparison <- comparison %>% 
      filter(year >= input$yearInput2[1],
             year <= input$yearInput2[2],
             real_name == input$cityInput2)
    
    
    {
      ggplot(comparison %>% filter(real_name == input$cityInput2))+
        geom_line(aes(x=year,y=total, color = type),size=1,alpha=0.7) + geom_point(aes(x=year,y=total)) +
        scale_x_continuous("Year") + scale_colour_brewer(palette = "Set1") +
        scale_y_continuous("# of Crimes",limits = c(0,3000))+
        ggtitle(paste("Crime Statistics for",input$cityInput2,"between :",input$yearInput2[1],"-",input$yearInput2[2]))+
        theme_bw()+
        theme(legend.position = "bottom") + labs(color = "")
    
      }
  })
  
  
#tables
  output$table1 <- renderTable({
    
    crime_table_1 <- crime_df %>% 
      filter(real_name == input$cityInput12,
             year %in% c(input$yearInput22[1],input$yearInput22[2])) %>% mutate(City = real_name, Crime = type) %>%
      select(City,year,Crime,quantity_rel) %>% 
      spread(year,quantity_rel)
    
    
  })
  
  output$table2 <- renderTable({
    crime_table_2 <- crime_df %>% 
      filter(real_name == input$cityInput22,
             year %in% c(input$yearInput22[1],input$yearInput22[2])) %>% mutate(City = real_name, Crime = type) %>%
      select(City,year,Crime,quantity_rel) %>% 
      spread(year,quantity_rel)
  })
})


# Run the application 
shinyApp(ui = shinyUI, server = shinyServer)
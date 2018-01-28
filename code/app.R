## US Crime Report
## Author: Akshi Chaudhary



## Required libraries
#install.packages("leaflet")
library(colourpicker)
library(dplyr)
library(gapminder)
library(ggplot2)
library(htmltools)
library(leaflet)
library(magrittr)
library(readr)
library(scales)
library(shiny)
library(shinydashboard)
library(shinythemes)
library(stringr)
library(tidyr)


# Setting up ggthemes

## https://rpubs.com/Koundy/71792
theme_Publication <- function(base_size=14) {
  library(grid)
  library(ggthemes)
  (theme_foundation(base_size=base_size)
    + theme(plot.title = element_text(face = "bold",
                                      size = rel(1.2), hjust = 0.5),
            text = element_text(),
            panel.background = element_rect(colour = NA),
            plot.background = element_rect(colour = NA),
            panel.border = element_rect(colour = NA),
            axis.title = element_text(face = "bold",size = rel(1)),
            axis.title.y = element_text(angle=90,vjust =2),
            axis.title.x = element_text(vjust = -0.2),
            axis.text = element_text(), 
            axis.line = element_line(colour="black"),
            axis.ticks = element_line(),
            panel.grid.major = element_line(colour="#f0f0f0"),
            panel.grid.minor = element_blank(),
            legend.key = element_rect(colour = NA),
            legend.position = "bottom",
            legend.direction = "horizontal",
            legend.key.size= unit(0.8, "cm"),
            legend.title = element_text(face="italic"),
            plot.margin=unit(c(10,5,5,5),"mm"),
            strip.background=element_rect(colour="#f0f0f0",fill="#f0f0f0"),
            strip.text = element_text(face="bold")
    ))
  
}

scale_fill_Publication <- function(...){
  library(scales)
  discrete_scale("fill","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")), ...)
  
}

scale_colour_Publication <- function(...){
  library(scales)
  discrete_scale("colour","Publication",manual_pal(values = c("#386cb0","#fdb462","#7fc97f","#ef3b2c","#662506","#a6cee3","#fb9a99","#984ea3","#ffff33")), ...)
  
}


## Data Import and processing

crime_dataset <- read_csv('crime_dataset.csv')
locations <- read_csv('locations.csv')

locations$lat <- as.numeric(locations$lat)
locations$long <- as.numeric(locations$long)

## create dataframe to gather crime numbers

crime <- data_frame(crime_type= c("violent_crime","homs_sum","rape_sum","rob_sum","agg_ass_sum"),
                    type = c("All","Homicide","Rape","Robbery","Aggravated Assault"))
crime_data <- crime_dataset %>% gather(crime_type,sums,5:9) %>% select(ORI,year,total_pop,crime_type,sums) %>% inner_join(crime) %>% select(-crime_type) %>% 
  inner_join(locations,by=c("ORI"="code")) %>% 
  ## calculate crime totals realtive to 100k population
  mutate(sums_rel = sums / total_pop * 100000) %>% 
  ## remove national average
  filter(city != "National")



## create states, cities lists for user select inputs

States <- sort(append(unique(locations$state),"ALL"))
Cities <- sort(append(unique(locations$city),"ALL"))
Compare <- sort(unique(locations$city))


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
              
              ### Code for map leaflet
              tabPanel("Map",
                       
                       fluidRow( sidebarPanel( width = 3,
                                               helpText("Use + / - to Zoom-in or Zoom-out on map\n Drag the map to adjust to scale\n"),
                                               helpText(""),
                                               
                                               helpText("Click on the bubble to view data"),
                                               
                                               helpText(""),
                                               
                                               helpText(""),
                                               helpText("Choose the crime to display on the map"),
                                               selectInput("crimeInput", "Type of Violent crime",
                                                           choices = c( "All","Homicide", "Rape","Robbery","Aggravated Assault")),
                                               helpText("Crimes since 1995"),
                                        
                                               sliderInput("yearInput", 
                                                           label = "Year",
                                                           sep = "",
                                                           min = 1995, max = 2015, value = 2007,step=1,animate=FALSE,dragRange= FALSE),
                                               uiOutput("stateControls"),
                                               helpText("\n The Crime rates have been normalised by \n population")
                                              # checkboxInput("relCheckbox", "Show crime relative to Population", value = FALSE)

                       ),
                       mainPanel(leafletOutput("map1",  height = 600, width= 800))
                       )
                       
                       
              ),
              
              ## Code for the Trends tab.
              
              tabPanel( "Trends",
                        fluidRow(sidebarPanel(width = 3,
                                              helpText("Choose the cities to compare crime rates"),
                                              
                                              selectInput("cityInput1", "City 1",
                                                          choices = Compare, selected = "San Francisco"),
                                              
                                              selectInput("cityInput2", "City 2", choices = Compare, selected = "New York"),
                                              
                                              
                                              sliderInput("yearInput2", 
                                                          label = "Year",
                                                          min = 1995, max = 2015, value = c(1975, 2015),step=1,animate=FALSE),
                                              
                                              helpText("Note the crime numbers shown are per 100k people \nin each city")
                        ),
                        
                        mainPanel(
                          
                          fluidRow(
                            splitLayout(cellWidths = c("50%"), plotOutput("plot1"),plotOutput("plot2"))
                          )
                          
                        )
                    )
          
              ),
              
              
              ### code for Data tab
              tabPanel( "Data",
                        fluidRow(sidebarPanel(width = 3,
                                              helpText("Select the City and time period for raw statistics"),
                                              #city
                                              selectInput("cityInput12", "Choose City",
                                                          choices = Compare, selected = "Chicago"),
                                              
                                              
                                              #year
                                              
                                              sliderInput("yearInput22", 
                                                          label = "Year",
                                                          min = 1995, max = 2015, value = c(1975, 2015),step=1,animate=FALSE),
                                              helpText("Note the crime numbers shown are per 100k people \nin each city"),
                                              
                                              # Button
                                              downloadButton("Dataset", "Download Data")
                        ),
                        
                        mainPanel(
                          
                          
                          fluidRow(
                            tableOutput("table1")
                          )
                          
                        )
   
                      )
        
              )
  )              
) 



##################### Server Logic starts here ################################

shinyServer <- (function(input, output) {
  # Map using leaflet
  
  output$map1 <- renderLeaflet({

    # Create data frame for previous year difference
    
    df <- crime_data %>% 
       arrange(year) %>% group_by(city,type) %>% 
      mutate(old_sum = lag(sums_rel), diff_rel = ((sums_rel - old_sum) /sums_rel)*100 , diff_rel = ifelse(is.na(diff_rel),0,diff_rel)) %>%  
      mutate(old = lag(sums), diff = ((sums - old_sum) /sums)*100, diff = ifelse(is.na(diff),0,diff)) %>%
      filter(year == input$yearInput,type == input$crimeInput) %>% mutate(sums = sums_rel)
    
   # df <- df %>% mutate(sums = sums_rel)
    
    
    radius <- 30/max(df$sums,na.rm=TRUE)
# https://rstudio.github.io/leaflet/colors.html    
    pal <- colorNumeric(
      palette = "Spectral",
      domain = df$diff)
    
    ## leaflet options, radius and zoom
    leaflet(data=df) %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      setView(lng = -93.85, lat = 37.45, zoom = 4) %>% 
      addTiles() %>%
      
      ### Circle bubble setting
      
      # Create a continuous palette function

      # https://rstudio.github.io/leaflet/markers.html
      addCircleMarkers(~long, 
                       ~lat,
                       popup = ~paste("</br><b>Crime:</b>",type,
                                      "</br><b>City:</b>",city,
                                      "</br><b>Year:</b>",year,
                                      "</br><b>Total:</b>",round(sums)),
                       label = ~as.character(city),
                       radius = ~(sums * radius),
                       stroke = FALSE, 
                       color = ~pal(diff),
                       fillOpacity = 0.5) 
  })
  
  
  ## Comparison data for trend plots
  
  comparison <- crime_data %>% group_by(city,year,type) %>% summarize(total=sum(sums_rel)) %>% mutate(Crime = ifelse(type=="Aggravated Assault", "Assualt",type))
  
  output$plot1 <- renderPlot({  
                comparison <- comparison %>% 
                  filter(year >= input$yearInput2[1], year <= input$yearInput2[2],city == input$cityInput1)
  
                
                ## PLot1  
    {
      ggplot(comparison %>% filter(city == input$cityInput1))+
        geom_line(aes(x=year,y=total, color = Crime),size=1,alpha=0.7) + geom_point(aes(x=year,y=total)) +
        scale_x_continuous("Year") + # scale_colour_brewer(palette = "Set1") +
        scale_y_continuous("# Crimes",limits = c(0,3000))+
        ggtitle(paste("Crime Statistics for",input$cityInput1,"\n",input$yearInput2[1],"-",input$yearInput2[2]))+
        labs(color = "") + scale_colour_Publication()+ theme_Publication()
      }
  })
  
  ## plot2
  
  output$plot2 <- renderPlot({
    comparison <- comparison %>% filter(year >= input$yearInput2[1],year <= input$yearInput2[2],city == input$cityInput2)
    
    
    {
      ggplot(comparison %>% filter(city == input$cityInput2)) +
        geom_line(aes(x=year,y=total, color = Crime),size=1,alpha=0.7) + geom_point(aes(x=year,y=total)) +
        scale_x_continuous("Year") + #scale_colour_brewer(palette = "Set1") +
        scale_y_continuous("# Crimes",limits = c(0,3000))+
        ggtitle(paste("Crime Statistics for",input$cityInput2,"\n",input$yearInput2[1],"-",input$yearInput2[2]))+
        labs(color = "") + scale_colour_Publication()+ theme_Publication()
      
      }
  })
  
  
  #table
  output$table1 <- renderTable({
    
    table1 <-crime_data %>%
      filter(city == input$cityInput12,year > input$yearInput22[1] & year < input$yearInput22[2]) %>% mutate(City = city, Crime = ifelse(type=="Aggravated Assault", "Assualt",type)) %>% 
      mutate(Crime = ifelse(Crime=="All", "All Crimes",Crime), Year = year, total = round(sums_rel)) %>%
      select(City,Year,Crime,total)  %>% arrange(desc(Crime)) %>%
      spread(Crime,total)  
    
  })
  
  # Downloadable csv of selected dataset ----
  output$Dataset <- downloadHandler(
    filename = function() {
      paste(input$cityInput12, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(table1, file, row.names = FALSE)
    }
  )
  
  
})


# Run the application 
shinyApp(ui = shinyUI, server = shinyServer)
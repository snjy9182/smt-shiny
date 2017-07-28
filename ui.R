#### ui.R
#### Wu Lab, Johns Hopkins University
#### Author: Sun Jay Yoo
#### Date: July 28, 2017

library(shiny)
library(shinyFiles)

shinyUI(fluidPage(
    
    h1("smt"),
    
    h3("Read Tracks"),
    
    sidebarPanel(
        
        radioButtons(inputId = "input", 
                     label = h5("Input type"), 
                     c("Diatrack .txt file" = 1, 
                       "Diatrack .mat session file" = 2, 
                       "ImageJ .csv file" = 3, 
                       "SlimFast .txt file" = 4), 
                     2),
        
        checkboxGroupInput(inputId = "parameters", 
                           label = h5("Parameters:"), 
                           choices =  c("Merge" = 1,
                                        "Use absolute coordinates" = 2,
                                        "Add frame record" = 3), 
                           selected =  3),
        
        sliderInput(inputId = "cores", 
                    label = h5("Cores for parallel computation"),
                    min=1, max=parallel::detectCores(logical = F), value=1, step = 1),
        
        actionButton(inputId = "read", 
                     label = "Select a file in the desired folder...",
                     icon = icon("folder-open"))
    ),
    
    h3("Process Tracks"),
    
    sidebarPanel(
        
        h4("Filter"),
        numericInput(inputId <- "minFilter", 
                     label = h5("Minimum track length"),
                     value = 7),
    
        numericInput(inputId <- "maxFilter", 
                     label = h5("Maximum track length (enter 0 for infinity)"), 
                     value = 0),
        
        actionButton(inputId = "filter", 
                     label = "Filter",
                     icon = icon("filter")),
        
        h4("Trim"),
        sliderInput(inputId = "trimRange", 
                    label = h5("Track length range"),
                    min = 1, max = 50, 
                    value = c(1, 10),
                    step = 1),
        actionButton(inputId = "trim", 
                     label = "Trim",
                     icon = icon("cut"))
        

    ),
    
    #h3("Analyze Tracks"),
    
    #h3("Read Track Data"),
    
    #h3("Read Track Data"),

    
    mainPanel(
        plotOutput("plotPoints")
        #h2("Track Plots"),
        #h2("Track Data")
        #textOutput("test")
    )
    
    
    
    
    
))
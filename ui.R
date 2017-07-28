#### ui.R
#### Wu Lab, Johns Hopkins University
#### Author: Sun Jay Yoo
#### Date: July 28, 2017

library(shiny)
library(smt)

shinyUI(fluidPage(
    
    titlePanel("smt", windowTitle = "smt"),
    
    tabsetPanel(
        tabPanel("1. Read Tracks",
             
            h3("Read Tracks"),
             
            sidebarPanel(
                 
                h3("Folder"),
                actionButton(inputId = "folder", 
                    label = "Select any file in the folder...",
                    icon = icon("folder-open")),
                    textOutput("folderConfirm"),
                     
                h3("Parameters"),
                radioButtons(inputId = "input", 
                    label = h5("Input type:"), 
                    c("Diatrack .txt file" = 1, 
                    "Diatrack .mat session file" = 2, 
                    "ImageJ .csv file" = 3, 
                    "SlimFast .txt file" = 4), 
                    selected = 2),
                     
                checkboxGroupInput(inputId = "parameters", 
                    label = h5("Parameters:"), 
                    choices =  c("Merge" = 1,
                    "Use absolute coordinates" = 2,
                    "Keep frame record" = 3), 
                    selected =  3),
                     
                sliderInput(inputId = "cores", 
                    label = h5("Cores for parallel computation:"),
                    min=1, max=parallel::detectCores(logical = F), 
                    value = 1, step = 1),
                     
                actionButton(inputId = "read", 
                    label = "Read folder",
                    icon = icon("clone")),
                textOutput("readConfirm")
            )
                 
                 
        ),
        tabPanel("2. Process Tracks",
                 
            h3("Process Tracks"),
             
            sidebarPanel(
             
                h3("Link"),
                numericInput(inputId <- "tolerance", 
                    label = h5("Tolerance level (pixels):"),
                    value = 5),
                numericInput(inputId <- "maxSkip", 
                    label = h5("Frame skips:"), 
                    value = 10,
                    step = 1),
                actionButton(inputId = "link", 
                    label = "Link",
                    icon = icon("link")),
                textOutput("linkConfirm"),
                     
                h3("Filter"),
                numericInput(inputId <- "minFilter", 
                    label = h5("Minimum track length:"),
                    value = 7),
                     
                numericInput(inputId <- "maxFilter", 
                    label = h5("Maximum track length (enter 0 for infinity):"), 
                    value = 0),
                actionButton(inputId = "filter", 
                    label = "Filter",
                    icon = icon("filter")),
                textOutput("filterConfirm"),
                     
                h3("Trim"),
                sliderInput(inputId = "trimRange", 
                    label = h5("Track length range:"),
                    min = 1, max = 50, 
                    value = c(1, 10),
                    step = 1),
                actionButton(inputId = "trim", 
                    label = "Trim",
                    icon = icon("cut")),
                textOutput("trimConfirm"),
                     
                h3("Mask"),
                radioButtons(inputId = "maskMethod", 
                    label = h5("Mask method:"), 
                    c("Image masks" = 1, 
                    "Kernel density clustering" = 2),
                    selected = 1),
                actionButton(inputId = "mask", 
                    label = "Mask",
                    icon = icon("braille")),
                textOutput("maskConfirm")
            )
                 
                 
        )
        
    ),
    
    mainPanel(
        
        h3("Track Info"),
        textOutput("trackllInfo"),
        textOutput("tracklInfo"),
        sliderInput(inputId = "tracklNum", 
            label = h5("Select video number:"),
            min = 1, max = 1,
            value = 1, 
            step = 1),
        
        h3("Export"),
        actionButton(inputId = "export", 
            label = "Export to working directory",
            icon = icon("download")),
        textOutput("exportConfirm"),
        
        h3("Track Plot"),
        radioButtons(inputId = "plotType", 
            label = h5("Plot type:"), 
            c("Coordinate Points" = 1, 
            "Trajectory Lines" = 2),
            selected = 1),
        
        plotOutput(outputId = "plotPoints",
                   width = "600px",
                   height = "600px")
    )
))
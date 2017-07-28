#### server.R
#### Wu Lab, Johns Hopkins University
#### Author: Sun Jay Yoo
#### Date: July 28, 2017

library(shiny)
library(smt)

shinyServer(function(input, output, session){
    trackll <- reactiveValues(data= NULL);
    folder <- reactiveValues(data = NULL);
    
    observeEvent(input$folder, {
        folder$data <- dirname(file.choose());
        output$folderConfirm <- renderText({
            paste("Folder chosen: ", folder$data, sep = "")
        })
    })
    
    observeEvent(input$read, {
        merge = F;
        ab.track = F;
        frameRecord = F;
        for(i in 1:length(input$parameters)){
            if (input$parameters[[i]] == 1){
                merge = T;
            } else if (input$parameters[[i]] == 2) {
                ab.track = T;
            } else if (input$parameters[[i]] == 3){
                frameRecord = T;
            }
        }
        trackll$data <- createTrackll(folder = folder$data,
                                 input = input$input,
                                 merge = merge,
                                 ab.track = ab.track,
                                 mask = FALSE,
                                 cores = input$cores,
                                 frameRecord = frameRecord)
        output$readConfirm <- renderText({
            print("Files read.")
        })
    })
    
    
    observeEvent(input$link, {
        trackll$data <- linkSkippedFrames(trackll = trackll$data, tolerance = input$tolerance, maxSkip = input$maxSkip, cores = input$cores)
        output$linkConfirm <- renderText({
            print("Linking completed.")
        })
    })
    
    observeEvent(input$filter, {
        if (input$maxFilter == 0){
            trackll$data <- filterTrack(trackll$data, filter = c(min = input$minFilter, max = Inf))
        } else {
            trackll$data <- filterTrack(trackll$data, filter = c(min = input$minFilter, max = input$maxFilter))
        }
        output$filterConfirm <- renderText({
            print("Filtering completed.")
        })
    })
    
    observeEvent(input$trim, {
        trackll$data <- trimTrack(trackll$data, trimmer = c(min = input$trimRange[[1]], max = input$trimRange[[2]]))
        output$trimConfirm <- renderText({
            print("Trimming completed.")
        })
    })
    
    observeEvent(input$mask, {
        if (input$maskMethod == 1){
            trackll$data <- maskTracks(folder$data, trackll$data)
        } else {
            trackll$data <- densityMaskTracks(trackll$data, automatic = T)#####NEED TO UPDATE
        }
        output$maskConfirm <- renderText({
            print("Masking completed.")
        })
    })
    
    observe({
        updateSliderInput(session, "tracklNum",
                          max = length(trackll$data))
    })
    
    output$plotPoints <- renderPlot({
        if (!is.null(trackll$data)){
            if (input$plotType == 1){
                .plotPoints(trackll$data[[input$tracklNum]])
            } else {
                .plotLines(trackll$data[[input$tracklNum]])
            }
        }
    })
    
    output$trackllInfo <- renderText({
        paste("Total number of videos:", length(trackll$data), sep = " ")
    })
    
    output$tracklInfo <- renderText({
        paste("Video",  input$tracklNum, "length:", length(trackll$data[[input$tracklNum]]), sep =" ")
    })
    
    observeEvent(input$export, {
        exportTrackll(trackll$data, cores = input$cores);
        output$exportConfirm <- renderText({
            paste("Exported to: ", getwd(), sep = "")
        })
    })
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
})
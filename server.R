#### server.R
#### Wu Lab, Johns Hopkins University
#### Author: Sun Jay Yoo
#### Date: July 28, 2017

library(shiny)
library(smt)

shinyServer(function(input, output, session){
    
    #Instantiate reactive values
    trackll <- reactiveValues(data= NULL);
    trackll.save <- reactiveValues(data= NULL);
    msd.trackll <- reactiveValues(data= NULL)
    folder <- reactiveValues(data = NULL);
    
    observeEvent(input$folder, {
        folder$data <- dirname(file.choose());
        output$folderConfirm <- renderText({
            paste("Folder chosen: ", folder$data, sep = "")
        })
    })
    
    #Read
    observeEvent(input$read, {
        ab.track = F;
        frameRecord = F;
        for(i in 1:length(input$parameters)){
            if (input$parameters[[i]] == 1){
                ab.track = T;
            } else if (input$parameters[[i]] == 2) {
                frameRecord = T;
            }
        }
        trackll$data <- createTrackll(folder = folder$data,
            input = input$input,
            ab.track = ab.track,
            cores = input$cores,
            frameRecord = frameRecord)
        trackll.save$data <- trackll$data;
        output$readConfirm <- renderText({
            print("Files read.")
        })
    })
    
    output$readNote <- renderText({
        print("Note: reading may take time.")
    })
    
    #Reset
    observeEvent(input$reset, {
        trackll$data <- trackll.save$data
    })
    
    #Link
    observeEvent(input$link, {
        trackll$data <- linkSkippedFrames(trackll = trackll$data, 
            tolerance = input$tolerance, 
            maxSkip = input$maxSkip, 
            cores = input$cores)
        output$linkConfirm <- renderText({
            print("Linking completed.")
        })
    })
    
    #Filter
    observeEvent(input$filter, {
        if (input$maxFilter == 0){
            trackll$data <- filterTrack(trackll$data, 
                filter = c(min = input$minFilter, max = Inf))
        } else {
            trackll$data <- filterTrack(trackll$data, 
                filter = c(min = input$minFilter, max = input$maxFilter))
        }
        output$filterConfirm <- renderText({
            print("Filtering completed.")
        })
    })
    
    #Trim
    observeEvent(input$trim, {
        trackll$data <- trimTrack(trackll$data, 
                trimmer = c(min = input$trimRange[[1]], max = input$trimRange[[2]]))
        output$trimConfirm <- renderText({
            print("Trimming completed.")
        })
    })
    
    #Mask
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
    
    #Mask
    observeEvent(input$merge, {
        trackll$data <- mergeTracks(folder$data, trackll$data)
        output$mergeConfirm <- renderText({
            print("Merging completed.")
        })
    })
    
    #Update trackl number slider to match data
    observe({
        updateSliderInput(session, 
            inputId = "tracklNum",
            max = length(trackll$data))
    })
    
    #Plot trackl
    output$plotPoints <- renderPlot({
        if (!is.null(trackll$data)){
            if (input$plotType == 1){
                .plotPoints(trackll$data[[input$tracklNum]])
            } else {
                .plotLines(trackll$data[[input$tracklNum]])
            }
        }
    }, width = 600, height = 600)
    
    #Print trackll info
    output$trackllInfo <- renderText({
        paste("Total number of videos: ", length(trackll$data), sep = " ")
    })
    
    #Print trackl info
    output$tracklInfo <- renderText({
        paste("Number of tracks in video ",  input$tracklNum, ":  ", length(trackll$data[[input$tracklNum]]), sep ="")
    })
    
    #Export current state trackll
    observeEvent(input$export, {
        exportTrackll(trackll$data, cores = input$cores);
        output$exportConfirm <- renderText({
            paste("Exported to: ", getwd(), sep = "")
        })
    })
    
    #MSD
    observeEvent(input$calculateMSD, {
        if (input$plotMSD){
            output$plotMSD <- renderPlot({
                msd.trackll$data <- msd(trackll$data, 
                    dt = input$dtMSD, 
                    resolution = input$resolutionMSD,
                    summarize = input$summarizeMSD, 
                    cores = input$cores,
                    plot = TRUE,
                    output = input$outputMSD)
            }, width = 900, height = 400)
            
            updateTabsetPanel(session, "mainTabsetPanel",
                selected = "Analysis Plots")
            
        } else {
            msd.trackll$data <- msd(trackll$data, 
                dt = input$dtMSD, 
                resolution = input$resolutionMSD,
                summarize = input$summarizeMSD, 
                cores = input$cores,
                plot = FALSE,
                output = input$outputMSD)
            
        }
        if (input$outputMSD){
            output$MSDConfirm <- renderText({
                paste("MSD calculted. Output exported to: ", getwd(), sep = "")
            })
        } else {
            output$MSDConfirm <- renderText({
                print("MSD calculated.")
            })
        }
    })
    
    #Dcoef
    observeEvent(input$calculateDcoef, {
        if (input$methodDcoef == 1){
            method <- "static"
        } else if (input$methodDcoef == 2){
            method <- "percentage"
        } else if (input$methodDcoef == 3){
            method <- "rolling.window"
        }
        
        if (input$binwidthDcoef == 0){
            binwidth <- NULL
        } else {
            binwidth <- input$binwidthDcoef
        }
        
        if (input$plotDcoef){
            output$plotDcoef <- renderPlot({
                Dcoef(MSD = msd.trackll$data,
                    trackll = trackll$data, 
                    dt = input$dtDcoef, 
                    rsquare = input$rsquareDcoef, 
                    resolution = input$resolutionDcoef, 
                    binwidth = binwidth, 
                    method = method, 
                    plot = TRUE, 
                    output = input$outputDcoef, 
                    t.interval = input$t.intervalDcoef)
            }, width = 900, height = 400)
            
            updateTabsetPanel(session, "mainTabsetPanel",
                selected = "Analysis Plots")
            
        } else {
            Dcoef(MSD = msd.trackll$data,
                trackll = trackll$data, 
                dt = input$dtDcoef, 
                rsquare = input$rsquareDcoef, 
                resolution = input$resolutionDcoef, 
                binwidth = binwidth, 
                method = method, 
                plot = FALSE, 
                output = input$outputDcoef, 
                t.interval = input$t.intervalDcoef)
            
        }
        if (input$outputDcoef){
            output$DcoefConfirm <- renderText({
                paste("Dcoef calculted. Output exported to: ", getwd(), sep = "")
            })
        } else {
            output$DcoefConfirm <- renderText({
                print("Dcoef calculated.")
            })
        }
    })
    
    #MSD present notification
    output$MSDpresent <- renderText({
        if (is.null(msd.trackll$data)){
            paste("WARNING: MSD has not been calculated.")
        } else {
            paste("MSD already calculated, ready for diffusion coefficient.")
        }
    })

})
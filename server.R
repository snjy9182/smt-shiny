library(shiny)
library(shinyFiles)

shinyServer(function(input, output){
    trackll <- reactive({})
    observeEvent(input$read, {
        #fileInput <- input$file
        #folder <- dirname(fileInput$datapath);
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
        trackll <- reactiveValues(data = createTrackll(interact = T,
                                 folder = NULL,
                                 input = input$input,
                                 merge = merge,
                                 ab.track = ab.track,
                                 mask = FALSE,
                                 cores = input$cores,
                                 frameRecord = frameRecord))
       
    })
    observeEvent(input$filter, {
        #if (input$maxFilter == 0){
        #    trackll <- filterTrack(trackll(), filter = c(min = input$minFilter, max = Inf))
        #} else {
        #    trackll <- filterTrack(trackll(), filter = c(min = input$minFilter, max = input$maxFilter))
        #}
        output$plotPoints <- renderPlot({
            plotPoints(trackll$data)
        })
    })
    
    observeEvent(input$trim, {
        trackll <- trimTrack(isolate(trackll), trimmer = c(min = input$trimRange[[1]], max = input$trimRange[[2]]))
        output$plotPoints <- renderPlot({
            plotPoints(isolate(trackll))
        })
    })
    
    
    
    
    
    
})
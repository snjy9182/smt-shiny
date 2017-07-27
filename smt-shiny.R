library(shiny)

ui <- fluidPage(
    sidebarPanel(
        radioButtons(inputId = "ab.track", label = "Calculate absolute coordinates", c(T = "T", F = "F"), "F"),
        radioButtons(inputId = "frameRecord", label = "Add frame record", c(T = "T", F = "F"), "T"),
        actionButton("do", "Read input")
    ),
    mainPanel(
        plotOutput("points")
    )
)

server <- function(input, output){
    
    observeEvent(input$do, {
        trackll <- .readDiaSessions(interact = T, ab.track = input$ab.track, frameRecord = input$frameRecord)
        output$points <- renderPlot({
            .plotPoints(trackll)
        })
    })    
}

shinyApp(ui = ui, server = server)
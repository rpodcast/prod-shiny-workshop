library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "obs",
        "Number of observations:",
        min = 10,
        max = 500,
        value = 100
      ),
      counterButton("counter1", "Counter #1")
    ),
    mainPanel(plotOutput("distPlot"))
  )
)

server <- function(input, output) {
  callModule(counter, "counter1")
  output$distPlot <- renderPlot({
    hist(rnorm(input$obs), col = 'darkgray', border = 'white')
  })
}


shinyApp(ui = ui, server = server)
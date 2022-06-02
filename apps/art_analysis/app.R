# To run app in this project, type following in R console:
# shiny::runApp("apps/art_analysis", port = 6789)
library(shiny)

ui <- navbarPage(
  title = "",
  collapsible = TRUE,
  tabPanel(
    title = "summary",
    "UIContent")
)

server <- function(input, output, session) {

}

shinyApp(ui = ui, server = server)
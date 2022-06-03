# To run app in this project, type following in R console:
# withr::with_envvar(new = c("R_CONFIG_ACTIVE" = "production"), withr::with_dir("apps/art_analysis", shiny::runApp(port = 6789)))
library(shiny)

ui <- navbarPage(
  title = "",
  collapsible = TRUE,
  tabPanel(
    title = "summary",
    "UIContent")
)

server <- function(input, output, session) {
  # establish connection to database
  # assumes postgres container is running
  message(glue::glue("production active? {tmp}", tmp = app_prod()))

  con <- db_con()
}

shinyApp(ui = ui, server = server)
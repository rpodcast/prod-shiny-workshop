# To run app in this project, type following in R console:
# shiny::runApp("apps/art_viewer")
library(shiny)
library(dplyr)
library(shinyvalidate)
library(shinylogs)

# data fields to display in app:
# title
# object_date
# credit_line
# classification
# department
# accession_year
# medium

# object_id == 571333
art_sub <- readRDS("data/art_sub.rds")

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  fluidRow(
    div(
      align = "center",
      uiOutput("img"),
      textOutput("metadata"),
      actionButton(
        "like",
        label = NULL,
        icon = icon("thumbs-up")
      ),
      actionButton(
        "dislike",
        label = NULL,
        icon = icon("thumbs-down")
      )
    )
  ),
  fluidRow(
    column(
      width = 4,
      tableOutput("choice_table")
    )
  )
)

server <- function(input, output, session) {

  # initialize logging
  track_usage(
    storage_mode = store_null()
  )
  
  # get first image
  first_image <- art_sub %>%
    slice_sample(n = 1) %>%
    pull(image_url)

  img_current <- reactiveVal(NULL)
  img_like <- reactiveVal(NULL)
  img_dislike <- reactiveVal(NULL)
  img_log <- reactiveVal(NULL)

  # reactive for art choices data frame
  # to be used in table 
  choice_df <- reactive({
    req(any(!is.null(img_like()), !is.null(img_dislike())))

    art_sub %>%
      filter(image_url %in% img_log()) %>%
      select(title, object_date, credit_line, classification, department, accession_year, medium)
  })

  metadata_rv <- reactive({
    req(img_current())

    tmp <- art_sub %>%
      filter(image_url == img_current()) %>%
      select(title, department) 

    glue::glue("{pull(tmp, title)} from {pull(tmp, department)}")
  })

  observeEvent(input$new_image, {
    img_exclude(c(img_exclude(), img_current()))
  })

  observeEvent(input$like, {
    img_like(c(img_like(), img_current()))
    img_log(c(img_log(), img_current()))
  })

  observeEvent(input$dislike, {
    img_dislike(c(img_dislike(), img_current()))
    img_log(c(img_log(), img_current()))
  })

  output$img <- renderUI({
    # select image 
    if (is.null(img_log())) {
      img_current(first_image)
    } else {
      img <- art_sub %>%
        filter(!image_url %in% img_log()) %>%
        slice_sample(n = 1) %>%
        pull(image_url)

      img_current(img)
    }

    tags$img(src = img_current())
  })

  output$metadata <- renderText({
    req(metadata_rv())
    metadata_rv()
  })

  output$choice_table <- renderTable({
    req(choice_df())
    choice_df()
  })
}


shinyApp(ui = ui, server = server)
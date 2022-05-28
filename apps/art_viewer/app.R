library(shiny)
library(dplyr)

art_sub <- readRDS("data/art_sub.rds")

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  fluidRow(
    div(
      align = "center",
      uiOutput("img"),
      actionButton(
        "new_image",
        "New Image"
      ),
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
  )
)

server <- function(input, output) {
  # get first image
  first_image <- art_sub %>%
    slice_sample(n = 1) %>%
    pull(image_url)

  img_exclude <- reactiveVal(NULL)
  img_current <- reactiveVal(NULL)
  img_like <- reactiveVal(NULL)
  img_dislike <- reactiveVal(NULL)

  observeEvent(input$new_image, {
    img_exclude(c(img_exclude(), img_current()))
  })

  observeEvent(input$like, {
    img_like(c(img_like(), img_current()))
  })

  observeEvent(input$dislike, {
    img_dislike(c(img_dislike(), img_current()))
    img_exclude(c(img_exclude(), img_current()))
  })

  output$img <- renderUI({
    # select image 
    if (is.null(img_exclude())) {
      img_current(first_image)
    } else {
      img <- art_sub %>%
        filter(!image_url %in% img_exclude()) %>%
        slice_sample(n = 1) %>%
        pull(image_url)

      img_current(img)
    }

    tags$img(src = img_current())
  })
}


shinyApp(ui = ui, server = server)
# To run app in this project, type following in R console:
# shiny::runApp("apps/art_viewer", port = 7777)
library(shiny)
library(dplyr)
library(shinyvalidate)
library(shinylogs)
library(shinyjs)
library(reactlog)

reactlog_enable()

art_sub <- readRDS("data/art_random.rds")
#all_data <- readRDS("data/all_random.rds")

ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tagList(
      htmltools::htmlDependency(
        name = "lightbox",
        version = "1.0.0",
        src = "lightbox",
        script = "lightbox.js",
        stylesheet = "lightbox.css",
        all_files = TRUE
      )
    )
  ),
  useShinyjs(),
  #shinya11y::use_tota11y(),
  extendShinyjs(script = "image_zoom.js", functions = c("zoomin", "zoomout")),
  fluidRow(
    column(
      width = 12,
      h2("The MET Image Viewer!")
    )
  ),
  fluidRow(
    div(
      align = "center",
      selectInput(
        "dept",
        "Department",
        choices = "",
        selected = "",
        multiple = TRUE
      )
    )
  ),
  fluidRow(
    div(
      align = "center",
      artviewer_UI("viewmod"),
      uiOutput("img"),
      textOutput("metadata"),
      actionButton(
        "zoom_in",
        label = "Zoom in"
      ),
      actionButton(
        "zoom_out",
        label = "Zoom out"
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
  ),
  fluidRow(
    column(
      width = 12,
      tableOutput("choice_table")
    )
  )
)

server <- function(input, output, session) {

  # initialize logging
  # track_usage(
  #   storage_mode = store_null()
  # )

  # establish key reactive values
  current_data <- reactiveVal(art_sub)
  choices_data <- reactiveVal(NULL)
  img_current <- reactiveVal(NULL)
  img_like <- reactiveVal(NULL)
  img_dislike <- reactiveVal(NULL)
  img_log <- reactiveVal(NULL)

  # update department choices based on available data
  observeEvent(current_data(), {

    # obtain unique list of departments
    department_choices <- current_data() %>%
      select(department) %>%
      distinct() %>%
      arrange(department) %>%
      pull(department)

    shiny::updateSelectInput(
      session,
      "dept",
      choices = department_choices,
      selected = department_choices
      )
  })

  # filter current available art by department
  observeEvent(input$dept, {
    current_data(
      filter(current_data(), department %in% input$dept)
    )
  })

  # reactive for the current image evaluation
  current_image_df <- reactive({
    df <- current_data() %>%
      slice_sample(n = 1)
    return(df)
  })
  
  artviewer_Server("viewmod", current_image_df)

  metadata_rv <- reactive({
    req(current_image_df())
    glue::glue("{pull(current_image_df(), title)} from {pull(current_image_df(), department)}")
  })

  observeEvent(input$like, {
    # grab currently viewed image df
    object_selected <- pull(current_image_df(), object_id)

    # add selected art object to choices_data reactive value
    choices_data(
      dplyr::bind_rows(choices_data(), current_image_df())
    )

    # remove selected object from current available art data
    current_data(
      dplyr::filter(current_data(), object_id != object_selected)
    )
  })

  observeEvent(input$dislike, {
    # grab currently viewed image df
    object_selected <- pull(current_image_df(), object_id)

    # remove selected object from current available art data
    current_data(
      dplyr::filter(current_data(), object_id != object_selected)
    )
  })

  output$img <- renderUI({
    req(current_image_df())
    tags$a(
      id = hashids::encode(1e3 + sample(1:1000, 1), hashids::hashid_settings(salt = 'this is my salt')),
      href = pull(current_image_df(), image_url),
      `data-lightbox` = 'g1',
      `data-title` = 'metadata',
      tags$img(src = pull(current_image_df(), image_url), id = "imgid", alt = "image alt text", class = "borderedpicture3")
    )
    #tags$img(src = pull(current_image_df(), image_url))
  })

  output$metadata <- renderText({
    req(metadata_rv())
    metadata_rv()
  })

  output$choice_table <- renderTable({
    req(choices_data())
    select(choices_data(), title, object_date, credit_line, classification, department, accession_year, medium)
  })

  observeEvent(input$zoom_in, {
    js$zoomin()
  })

  observeEvent(input$zoom_out, {
    js$zoomout()
  })
}

shinyApp(ui = ui, server = server)
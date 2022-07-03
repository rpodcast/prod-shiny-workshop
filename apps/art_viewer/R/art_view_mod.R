artviewer_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(
      div(
        align = "center",
        uiOutput(ns("img")),
        uiOutput(ns("metadata")),
        actionButton(
          ns("zoom_in"),
          label = "Zoom in"
        ),
        actionButton(
          ns("zoom_out"),
          label = "Zoom out"
        ),
        actionButton(
          ns("like"),
          label = NULL,
          icon = icon("thumbs-up")
        ),
        actionButton(
          ns("dislike"),
          label = NULL,
          icon = icon("thumbs-down")
        )
      )
    ),
  )
}

artviewer_Server <- function(id, current_image_df) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # render image
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
      
      # render metadata
      output$metadata <- renderUI({
        req(current_image_df())
        # using the standard html tags from htmltools
        tagList(
          p(glue::glue("Title: {pull(current_image_df(), title)}")),
          p(glue::glue("Artist: {pull(current_image_df(), artist_display_name)}")),
          p(glue::glue("Date Created: {pull(current_image_df(), object_begin_date)}")),
          p(glue::glue("Physical Dimensions: {pull(current_image_df(), dimensions)}")),
          p(glue::glue("Type: {pull(current_image_df(), object_name)}")),
          p(glue::glue("Medium: {pull(current_image_df(), medium)}")),
          p(glue::glue("Country of origin: {pull(current_image_df(), country)}")),
          p(glue::glue("Period: {pull(current_image_df(), period)}")),
          p(glue::glue("Culture: {pull(current_image_df(), culture)}")),
          p(glue::glue("Department: {pull(current_image_df(), department)}")),
          p("External Link: ", tags$a(href = pull(current_image_df(), link_resource), pull(current_image_df(), link_resource)))
        )
      })
      
      observeEvent(input$zoom_in, {
        js$zoomin()
      })
      
      observeEvent(input$zoom_out, {
        js$zoomout()
      })
    }
  )
}
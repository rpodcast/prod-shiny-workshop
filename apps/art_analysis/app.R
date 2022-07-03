# To run app in this project, type following in R console:
# withr::with_envvar(new = c("R_CONFIG_ACTIVE" = "default"), withr::with_dir("apps/art_analysis", shiny::runApp(port = 6789)))
# withr::with_envvar(new = c("R_CONFIG_ACTIVE" = "production"), withr::with_dir("apps/art_analysis", shiny::runApp(port = 6789)))
library(shiny)
library(dplyr)
library(dbplyr)
library(pool)
library(dm)

con <- db_con()

con_dm <- dm_from_src(con)

con_dm_keys <- con_dm %>%
  dm_add_pk(art, object_id) %>%
  dm_add_fk(label_annotations, image_file, art) %>%
  dm_add_fk(image_properties_annotation, image_file, art) %>%
  dm_add_fk(object_annotations, image_file, art) %>%
  dm_add_fk(crop_hints_annotation, image_file, art)

onStop(function() {
  pool::poolClose(pool = con)
})


ui <- navbarPage(
  title = "",
  collapsible = TRUE,
  tabPanel(
    value = "sum",
    title = "summary",
    fluidRow(
      column(
        width = 4,
        selectInput(
          "dept",
          "Select Department",
          choices = c(),
          multiple = FALSE
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        DT::DTOutput("time_table")
      )
    )
  ),
  tabPanel(
    value = "tab2",
    title = "Tab 2",
    "UI Content 2"
  )
)

server <- function(input, output, session) {

  # establish connection to database
  # assumes postgres container is running
  message(glue::glue("production active? {tmp}", tmp = app_prod()))
  
  
  
  output$time_table <- DT::renderDT({
    con_dm_keys %>%
      dm_zoom_to(art) %>%
      mutate(object_time_create = object_end_date - object_begin_date) %>%
      filter(object_time_create > 10000) %>%
      select(department, classification, title, period, object_begin_date, object_end_date, object_time_create) %>%
      arrange(desc(object_time_create)) %>%
      collect()
  })

}

shinyApp(ui = ui, server = server)
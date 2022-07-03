library(rsconnect)

my_app_files <- withr::with_dir(
  "apps/art_viewer", 
  c(
    "app.R",
    fs::dir_ls("data"),
    fs::dir_ls("www"),
    fs::dir_ls("R"),
    fs::dir_ls("lightbox")
  )
)

# likely need to run this once if in docker container
# NOT WORKING in VS-Code (complains about server not found)
# NOT WORKING IN RStudio (via docker) either
rsconnect::connectApiUser(
  server = Sys.getenv("CONNECT_SERVER"),
  apiKey = Sys.getenv("CONNECT_API_KEY")
)

# this works after getting the account set up via the RStudio IDE
withr::with_dir(
  "apps/art_viewer", 
  rsconnect::deployApp(
    appDir = getwd(),
    appName = "art_viewer",
    appFiles = my_app_files,
    launch.browser = FALSE,
    lint = FALSE,
    forceUpdate = TRUE
  )
)

# obtaining rstudio connect metrics
library(connectapi)

client <- connect(
  server = Sys.getenv("CONNECT_SERVER"),
  api_key = Sys.getenv("CONNECT_API_KEY")
)

usage_shiny <- get_usage_shiny(client)
all_content <- get_content(client)

user_df <- get_users(client, limit = Inf)

create_tag(client, "shinyprod")

# using other functions that don't have wrappers via API
library(httr)

# list all tags on server
result <- GET(glue::glue("{server}/__api__/v1/tags", server = Sys.getenv("CONNECT_SERVER")),
              add_headers(Authorization = paste("Key", Sys.getenv("CONNECT_API_KEY"))))

payload <- content(result)

# ensuring basic stuff works (Yes it does)
connectServer <- Sys.getenv("CONNECT_SERVER")
connectAPIKey <- Sys.getenv("CONNECT_API_KEY")

# Request a page of up to 25 usage records.
resp <- GET(
  glue::glue("{connectServer}/__api__/v1/instrumentation/shiny/usage?limit=25"),
  add_headers(Authorization = paste("Key", connectAPIKey))
)
payload <- content(resp)
# print the current page results
print(payload$results)

# experiment wtih connectViz
# https://github.com/RinteRface/connectViz
library(connectViz)
library(dplyr)

rsc_client <- create_rsc_client()

apps_usage <- rsc_client %>% get_usage_shiny(limit = Inf)
rsc_content <- rsc_client %>% get_content()
rsc_users <- rsc_client %>% get_users(limit = Inf)
publishers <- rsc_users %>% filter(user_role == "publisher") 
shiny_apps <- rsc_content %>% filter(app_mode == "shiny")

general_metrics <- list(
  "Onboarded Users (n)" = nrow(rsc_users),
  "Publishers (n)" = nrow(publishers),
  "Deployments (n)" = nrow(rsc_content),
  "Shiny Apps (n)" = nrow(shiny_apps)
)

apps_ranking <- create_app_ranking(rsc_content, rsc_users, apps_usage)
create_app_ranking_table(apps_ranking)

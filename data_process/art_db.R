# load MET art data into database
# Subset for only public domain and single-artist work
# Assumes you have downloaded the CSV files to the prototyping directory
# https://github.com/metmuseum/openaccess/blob/master/MetObjects.csv
# https://github.com/gregsadetsky/open-access-is-great-but-where-are-the-images/blob/main/1.data/met-images.csv

# assumes you are running the postgres docker database container
# see the workshop_db service in .devcontainer/docker-compose.yml

library(dplyr)
library(readr)
library(janitor)

# "35378.jpg"


# import csv and clean column names
art_data <- readr::read_csv(file.path(here::here(), "prototyping/MetObjects.csv")) %>%
  clean_names()

# compute frequencies
tabyl(art_data, is_highlight)

art_images <- readr::read_csv(file.path(here::here(), "prototyping/met-images.csv")) %>%
  mutate(image_file = fs::path_file(image_url))

art_single <- art_data %>%
  filter(is_public_domain) %>%
  mutate(mult_ind = stringr::str_detect(artist_display_name, "|")) %>%
  filter(is.na(mult_ind)) %>%
  select(., -mult_ind)

art_images_single <- art_images %>%
  group_by(object_id) %>%
  slice_sample(n = 1) %>%
  ungroup() %>%
  filter(object_id %in% art_single$object_id)
  #count(object_id)

art_single_image <- art_single %>%
  left_join(art_images_single, by = "object_id") %>%
  filter(!is.na(image_url)) %>%
  filter(!is.na(title)) %>%
  group_by(image_file) %>%
  slice_sample(n = 1) %>%
  ungroup()

df <- filter(art_single_image, image_file == "35378.jpg")

# establish connection to local container with database
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "workshopdb",
  dbname = "postgres",
  port = 5432,
  user = "postgres",
  password = "shiny"
)

# write table to DB
DBI::dbListTables(con)
DBI::dbWriteTable(con, "art", art_single_image)

# verify that the table works for exploration

art_db <- tbl(con, "art")

art_explore <- art_db %>%
  slice_sample(n = 50) %>%
  collect()
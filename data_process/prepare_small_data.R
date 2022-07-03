# revised version with updated database and Google Vision API results

library(dplyr)
library(dbplyr)
library(tidyr)
library(dm)

# establish connection to local container with database
con <- DBI::dbConnect(
  RPostgres::Postgres(),
  host = "workshopdb",
  dbname = "postgres",
  port = 5432,
  user = "postgres",
  password = "shiny"
)

con_dm <- dm_from_src(con)

con_dm_keys <- con_dm %>%
  dm_add_pk(art, columns = image_file) %>%
  dm_add_fk(label_annotations, image_file, art) %>%
  dm_add_fk(image_properties_annotation, image_file, art) %>%
  dm_add_fk(object_annotations, image_file, art) %>%
  dm_add_fk(crop_hints_annotation, image_file, art)

DBI::dbListTables(con)

# for each gcv table, grab the image files

crop_image_files <- tbl(con, "crop_hints_annotation") %>%
  select(image_file) %>%
  distinct() %>%
  collect() %>%
  pull(image_file) %>%
  unique()

label_annotation_image_files <- tbl(con, "label_annotations") %>%
  select(image_file) %>%
  distinct() %>%
  collect() %>%
  pull(image_file)

image_annotation_files <- tbl(con, "image_properties_annotation") %>%
  select(image_file) %>%
  distinct() %>%
  collect() %>%
  pull(image_file) %>%
  unique()

object_annotations_files <- tbl(con, "object_annotations") %>%
  select(image_file) %>%
  distinct() %>%
  collect() %>%
  pull(image_file) %>%
  unique()

# https://stackoverflow.com/a/3695700
common_image_files <- Reduce(intersect, list(crop_image_files, label_annotation_image_files, image_annotation_files, object_annotations_files))

# goal: obtain a subset that mimics the proportions of artwork for each department


art_meta <- tbl(con, "art") %>%
  filter(image_file %in% common_image_files) %>%
  collect() %>%
  group_by(image_file) %>%
  slice_sample(n = 1) %>%
  ungroup()

saveRDS(art_meta, file = fs::path(here::here(), "data_process", "art_meta.rds"))

# we see that "Photographs" and "The Libraries" only have one record each
# save this sumamry set for slides and/or apps


dept_summary <- art_meta %>% 
  count(department) %>% 
  arrange(desc(n))

saveRDS(dept_summary, file = fs::path(here::here(), "data_process", "dept_summary.rds"))

#https://jennybc.github.io/purrr-tutorial/ls12_different-sized-samples.html
set.seed(876)
art_random <- art_meta %>%
  filter(!department %in% c("Photographs", "The Libraries")) %>%
  group_by(department) %>%
  tidyr::nest() %>%
  ungroup() %>%
  left_join(dept_summary) %>%
  mutate(n_small = round(n * 0.005), 1) %>%
  mutate(samp = map2(data, n_small, dplyr::sample_n)) %>%
  select(-data, -n, -n_small) %>%
  unnest(samp)

saveRDS(art_random, file = fs::path(here::here(), "data_process", "art_random.rds"))

# now let's obtain custom exports of the google vision API data using these images
art_image_files <- unique(art_random$image_file)

crop_df <- tbl(con, "crop_hints_annotation") %>%
  filter(image_file %in% art_image_files) %>%
  collect()

saveRDS(crop_df, file = fs::path(here::here(), "data_process", "crop_df.rds"))

label_annotation_df <- tbl(con, "label_annotations") %>%
  filter(image_file %in% art_image_files) %>%
  collect()

saveRDS(label_annotation_df, file = fs::path(here::here(), "data_process", "label_annotation_df.rds"))

object_annotation_df <- tbl(con, "object_annotations") %>%
  filter(image_file %in% art_image_files) %>%
  collect()

saveRDS(object_annotation_df, file = fs::path(here::here(), "data_process", "object_annotation_df.rds"))

image_annotation_df <- tbl(con, "image_properties_annotation") %>%
  filter(image_file %in% art_image_files) %>%
  collect()

saveRDS(image_annotation_df, file = fs::path(here::here(), "data_process", "image_annotation_df.rds"))

# now for one complete table just in case
# not working, so have to do this the old fashioned way
all_random <- art_random %>%
  left_join(crop_df) %>%
  left_join(label_annotation_df) %>%
  left_join(object_annotation_df) %>%
  left_join(image_annotation_df)

saveRDS(all_random, file = fs::path(here::here(), "data_process", "all_random.rds"))


con_dm_random <- con_dm_keys %>%
  dm_filter(art, image_file %in% art_image_files)

all_random <- con_dm_random %>%
  dm_flatten_to_tbl(start = crop_hints_annotation, art) %>%
  collect()
  
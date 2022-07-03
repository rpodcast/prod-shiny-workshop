library(dplyr)
library(dbplyr)
library(dm)

## Database cleanup

# We have quite a few image files that were processed by the Google Vision API that are not present in the original art.csv file 
# that is the source of the metadata. We will use functions from `{dm}` to pinpoint which image files are not present. 

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


names(con_dm_keys)

label_not <- con_dm_keys %>%
  dm_join_to_tbl(label_annotations, art, join = anti_join) %>%
  select(image_file) %>%
  distinct() %>%
  collect()

image_not <- con_dm_keys %>%
  dm_join_to_tbl(image_properties_annotation, art, join = anti_join) %>%
  select(image_file) %>%
  distinct() %>%
  collect()

object_not <- con_dm_keys %>%
  dm_join_to_tbl(object_annotations, art, join = anti_join) %>%
  select(image_file) %>%
  distinct() %>%
  collect()

crop_not <- con_dm_keys %>%
  dm_join_to_tbl(crop_hints_annotation, art, join = anti_join) %>%
  select(image_file) %>%
  distinct() %>%
  collect()

# crop_not and image_not have the same images
diff_images <- setdiff(crop_not, image_not)
nrow(diff_images) < 1

# Find images that are extra in the crop_not and image_not data sets and not present in object_not
extra_images <- setdiff(crop_not, object_not)

dplyr::near(nrow(crop_not) - nrow(extra_images), nrow(object_not))

# we will remove these images from each of the GCV tables and write back out to the database
images_to_remove <- dplyr::pull(image_not)

# update each data table one by one
con_dm_revised <- con_dm_keys %>%
  dm_zoom_to(label_annotations) %>%
  filter(!image_file %in% images_to_remove) %>%
  compute() %>%
  dm_update_zoomed() %>%
  dm_zoom_to(object_annotations) %>%
  filter(!image_file %in% images_to_remove) %>%
  compute() %>%
  dm_update_zoomed() %>%
  dm_zoom_to(crop_hints_annotation) %>%
  filter(!image_file %in% images_to_remove) %>%
  compute() %>%
  dm_update_zoomed() %>%
  dm_zoom_to(image_properties_annotation) %>%
  filter(!image_file %in% images_to_remove) %>%
  compute() %>%
  dm_update_zoomed()

### DOES NOT WORK
#table_names = c("art_new", "object_annotations_new", "crop_hints_annotation_new", "label_annotations_new", "image_properties_annotation_new")
#copy_dm_to(con, con_dm_revised, temporary = FALSE)

# try individual tables
object_annotations_new_df <- con_dm_revised %>%
  dm_zoom_to(object_annotations) %>%
  collect()

# write to DB table
DBI::dbWriteTable(con, "object_annotations_new", object_annotations_new_df)

crop_hints_annotation_new_df <- con_dm_revised %>%
  dm_zoom_to(crop_hints_annotation) %>%
  collect() 

DBI::dbWriteTable(con, "crop_hints_annotation_new", crop_hints_annotation_new_df)

label_annotations_new_df <- con_dm_revised %>%
  dm_zoom_to(label_annotations) %>%
  collect()

DBI::dbWriteTable(con, "label_annotations_new", label_annotations_new_df)

#TODO: Finish with remaining tables

image_properties_annotation_new_df <- con_dm_revised %>%
  dm_zoom_to(image_properties_annotation) %>%
  collect()

DBI::dbWriteTable(con, "image_properties_annotation_new", image_properties_annotation_new_df)


con_dm_revised %>%
  dm_zoom_to(crop_hints_annotation) %>%
  compute() %>%
  dm_insert_zoomed("crop_hints_annotation_new")

con_dm_revised %>%
  dm_zoom_to(label_annotations) %>%
  compute() %>%
  dm_insert_zoomed("label_annotations_new")

con_dm_revised %>%
  dm_zoom_to(image_properties_annotation) %>%
  compute() %>%
  dm_insert_zoomed("image_properties_annotation_new")

# remove previous versions of tables
DBI::dbRemoveTable(con, "label_annotations")
DBI::dbRemoveTable(con, "crop_hints_annotation")
DBI::dbRemoveTable(con, "object_annotations")
DBI::dbRemoveTable(con, "image_properties_annotation")

# rename new version to match old version names
DBI::dbExecute(con, "ALTER TABLE label_annotations_new RENAME to label_annotations")
DBI::dbExecute(con, "ALTER TABLE crop_hints_annotation_new RENAME to crop_hints_annotation")
DBI::dbExecute(con, "ALTER TABLE object_annotations_new RENAME to object_annotations")
DBI::dbExecute(con, "ALTER TABLE image_properties_annotation_new RENAME to image_properties_annotation")
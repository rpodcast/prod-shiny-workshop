library(shinyloadtest)

# record an app session
record_session(
  target_app_url = "https://rsc.training.rstudio.com/art_viewer/",
  output_file = "prototyping/art_viewer_session.log",
  connect_api_key = Sys.getenv("CONNECT_API_KEY")
)

# change to the prototyping directory and run following command in terminal:

# baseline run 
# shinycannon art_viewer_session.log https://rsc.training.rstudio.com/art_viewer/ --workers 1 --loaded-duration-minutes 3 --overwrite-output --output-dir art_run1

# comparison run
# shinycannon art_viewer_session.log https://rsc.training.rstudio.com/art_viewer/ --workers 5 --loaded-duration-minutes 3 --overwrite-output --output-dir art_run2

# load data for analysis
df <- load_runs(
  "run1" = "prototyping/art_run1",
  "run2" = "prototyping/art_run2"
)

shinyloadtest_report(df, "prototyping/report.html")
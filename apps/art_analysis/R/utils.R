# custom function to determine if app running in dev or prd mode
app_prod <- function() {
  config::is_active("production")
}

# custom database connection function
db_con <- function() {
  vals <- config::get()
  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    host = vals[["db_host"]],
    dbname = vals[["dbname"]],
    port = vals[["db_port"]],
    user = vals[["db_user"]],
    password = vals[["db_password"]]
  )

  return(con)
}
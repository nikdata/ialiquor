## code to prepare `DATASET` dataset goes here

# Data retrieval

# define function to build the Socrata SoQL URL - CAUTION: No error handling built here
url_builder <- function(dataset_url, select, group, where, order, limit) {
  
  base_url <- dataset_url
  select_statement = paste0('$select=',select)
  group_statement = paste0('$group=', group)
  where_statement = paste0('$where=', where)
  order_statement = paste0('$order=', order)
  limit_statement = paste0('$limit=', limit)
  complete_url <- paste0(base_url, select_statement, '&', group_statement, '&', where_statement, '&', order_statement, '&', limit_statement)
  complete_url <- gsub(pattern = ' ', replacement = '%20', x = complete_url)
  
  return(complete_url)
  
}

# define function to retrieve the results; MAY REQUIRE API TOKEN
get_results <- function(url) {
  
  email = Sys.getenv("SOCRATA_EMAIL")
  pw = Sys.getenv("SOCRATA_PW")
  api_token = Sys.getenv("SOCRATA_TOKEN")
  
  content <- httr::content(
    httr::GET(
      url = url,
      httr::authenticate(user = email, password = pw),
      httr::add_headers("X-App-Token" = api_token)
    )
  )
  
  ans = tibble::tibble(as.data.frame(content))
  
  # ans <- url %>%
  #   httr::GET(
  #     httr::authenticate(user = email, password = pw),
  #     httr::add_headers("X-App-Token" = api_token)
  #   ) %>%
  #   httr::content() %>%
  #   as.data.frame() %>%
  #   tibble::tibble()
  
  return(ans)
}

# define the parameters
county_url <- url_builder(
  dataset_url = 'https://data.iowa.gov/resource/m3tr-qhgy.csv?',
  select = "date_trunc_ym(date) as year_mon, county, county_number, sum(state_bottle_cost * sale_bottles) as state_cost, sum(sale_bottles) as bottles_sold, sum(sale_dollars) as retail_revenue, sum(sale_liters) as liters_sold",
  group = "date_trunc_ym(date), county, county_number",
  where = "date >= '2012-01-01T00:00:00.000' and county is not null",
  order = "date_trunc_ym(date)",
  limit = 999999
)

category_url <- url_builder(
  dataset_url = 'https://data.iowa.gov/resource/m3tr-qhgy.csv?',
  select = "date_trunc_ym(date) as year_mon, category_name, sum(state_bottle_cost * sale_bottles) as state_cost, sum(sale_bottles) as bottles_sold, sum(sale_dollars) as retail_revenue, sum(sale_liters) as liters_sold",
  group = "date_trunc_ym(date), category_name",
  where = "date >= '2012-01-01T00:00:00.000' and county is not null",
  order = "date_trunc_ym(date)",
  limit = 999999
)

county_results <- get_results(url = county_url)
category_results <- get_results(url = category_url)

head(county_results)
head(category_results)

write.csv(county_results, 'csv/county_results.csv', row.names = FALSE)
write.csv(category_results, 'csv/category_results.csv', row.names = FALSE)

usethis::use_data(county_results, overwrite = TRUE)
usethis::use_data(category_results, overwrite = TRUE)

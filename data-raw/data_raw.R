## code to prepare `DATASET` dataset goes here

# import
`%>%` <- magrittr::`%>%`

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
  where = "date >= '2016-01-01T00:00:00.000' and county is not null and county_number is not null",
  order = "date_trunc_ym(date)",
  limit = 999999
)

category_url <- url_builder(
  dataset_url = 'https://data.iowa.gov/resource/m3tr-qhgy.csv?',
  select = "date_trunc_ym(date) as year_mon, category_name, sum(state_bottle_cost * sale_bottles) as state_cost, sum(sale_bottles) as bottles_sold, sum(sale_dollars) as retail_revenue, sum(sale_liters) as liters_sold",
  group = "date_trunc_ym(date), category_name",
  where = "date >= '2016-01-01T00:00:00.000' and county is not null and county_number is not null",
  order = "date_trunc_ym(date)",
  limit = 999999
)

county_sales <- get_results(url = county_url)
category_sales <- get_results(url = category_url)

head(county_sales)
head(category_sales)

str(county_sales)
str(category_sales)

# rearrange county_sales columns & remove attributes
county_sales <- county_sales %>%
  dplyr::transmute(
    year_mon,
    county,
    county_number = as.integer(county_number),
    state_cost,
    retail_revenue,
    bottles_sold,
    liters_sold
  ) %>%
  dplyr::group_by(
    year_mon,
    county,
    county_number,
    state_cost,
    retail_revenue,
    bottles_sold,
    liters_sold
  ) %>%
  dplyr::ungroup()

# need to convert category_name to all lower case
category_sales <- category_sales %>%
  dplyr::mutate(
    category_name = stringr::str_to_lower(category_name)
  ) %>%
  dplyr::group_by(
    year_mon, category_name
  ) %>%
  dplyr::summarize(
    state_cost = sum(state_cost),
    bottles_sold = sum(bottles_sold),
    retail_revenue = sum(retail_revenue),
    liters_sold = sum(liters_sold),
    .groups = 'keep'
  ) %>%
  dplyr::ungroup()

# clear up names & add a higher level category called type
category_sales <- category_sales %>%
  dplyr::mutate(
    type = dplyr::case_when(
      is.na(category_name) ~ 'unknown',
      stringr::str_detect(string = category_name, pattern = 'vodka') ~ 'vodka',
      stringr::str_detect(string = category_name, pattern = 'gin') & !stringr::str_detect(string = category_name, pattern = 'virgin')  ~ 'gin',
      stringr::str_detect(string = category_name, pattern = 'schnap') ~ 'schnapps',
      stringr::str_detect(string = category_name, pattern = 'tequila') ~ 'tequila',
      stringr::str_detect(string = category_name, pattern = 'brandies') | stringr::str_detect(string = category_name, pattern = 'brandy') ~ 'brandy',
      stringr::str_detect(string = category_name, pattern = 'rum') ~ 'rum',
      stringr::str_detect(string = category_name, pattern = 'bourbon') | stringr::str_detect(string = category_name, pattern = 'whisk') | stringr::str_detect(string = category_name, pattern = 'scotch') ~ 'whiskey',
      stringr::str_detect(string = category_name, pattern = 'beer') ~ 'beer',
      stringr::str_detect(string = category_name, pattern = 'amaretto') | stringr::str_detect(string = category_name, pattern = 'liqueur') | stringr::str_detect(string = category_name, pattern = 'anise') | stringr::str_detect(string = category_name, pattern = 'creme') ~ 'liqueur',
      stringr::str_detect(string = category_name, pattern = 'rock') | stringr::str_detect(string = category_name, pattern = 'cocktail') ~ 'cocktail',
      TRUE ~ 'other'
    )
  )

# rearrange columns
category_sales <- category_sales %>%
  dplyr::transmute(
    year_mon,
    type,
    category = category_name,
    state_cost,
    retail_revenue,
    bottles_sold,
    liters_sold
  )

write.csv(county_sales, 'csv/county_sales.csv', row.names = FALSE)
write.csv(category_sales, 'csv/category_sales.csv', row.names = FALSE)

usethis::use_data(county_sales, overwrite = TRUE)
usethis::use_data(category_sales, overwrite = TRUE)

# import pipe
`%>%` <- magrittr::`%>%`

# Data retrieval ----

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
  
  return(ans)
}

# define the URLs

pop_url <- url_builder(
  dataset_url = 'https://data.iowa.gov/resource/qtnr-zsrc.csv?',
  select = 'geographicname as county, date_extract_y(year) as cal_year, population',
  group = "",
  where = "date_extract_y(year)>=2015",
  order = "geographicname, date_extract_y(year)",
  limit = 999999
)

all_url <- url_builder(
  dataset_url = 'https://data.iowa.gov/resource/m3tr-qhgy.csv?',
  select = "date_trunc_ym(date) as year_month, county, category_name, sum(state_bottle_cost * sale_bottles) as state_cost, sum(sale_bottles) as bottles_sold, sum(sale_dollars) as state_revenue, sum(sale_liters) as volume",
  group = "date_trunc_ym(date), county, category_name",
  where = "date >= '2015-01-01T00:00:00.000' and county is not null",
  order = "date_trunc_ym(date)",
  limit = 9999999
  
)

# retrive the results
population <- get_results(url = pop_url)
liquor_sales <- get_results(url = all_url)

# Preview ----
head(population)
head(liquor_sales)

str(population)
str(liquor_sales)

# Data Cleaning ----

# clean up liquor sales
liquor_sales <- liquor_sales %>%
  dplyr::mutate(
    county = tolower(county),
    category_name = tolower(category_name),
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
    ),
    category_name = dplyr::case_when(
      stringr::str_detect(string = category_name, pattern = 'american cordials & liqueurs') ~ 'american cordials & liqueur',
      stringr::str_detect(string = category_name, pattern = 'american distilled spirits specialty') ~ 'american distilled spirit specialty',
      stringr::str_detect(string = category_name, pattern = 'flavored gins') ~ 'flavored gin',
      stringr::str_detect(string = category_name, pattern = 'american vodkas') ~ 'american vodka',
      stringr::str_detect(string = category_name, pattern = 'cocktails /rtd') ~ 'cocktails / rtd',
      stringr::str_detect(string = category_name, pattern = 'imported cordials & liqueurs') ~ 'imported cordials & liqueur',
      stringr::str_detect(string = category_name, pattern = 'imported distilled spirits specialty') ~ 'imported distilled spirit specialty',
      stringr::str_detect(string = category_name, pattern = 'imported vodkas') ~ 'imported vodka',
      stringr::str_detect(string = category_name, pattern = 'temporary  & specialty packages') | stringr::str_detect(string = category_name, pattern = 'temporary &  specialty packages') ~ 'temporary & specialty packages',
      TRUE ~ category_name
    )
  ) %>%
  dplyr::group_by(
    year_month, county, category_name, type
  ) %>%
  dplyr::summarize(
    state_cost = sum(state_cost),
    bottles_sold = sum(bottles_sold),
    state_revenue = sum(state_revenue),
    volume = sum(volume),
    .groups = 'keep'
  ) %>%
  dplyr::ungroup()

# remove word county from `county` and make all lowercase
population <- population %>%
  dplyr::mutate(
    county = tolower(gsub(pattern = ' County', replacement = '', x = county)),
  ) %>%
  dplyr::rename(
    year = cal_year
  )

# combine liquor sales and population
liquor_sales <- liquor_sales %>%
  dplyr::mutate(
    year = lubridate::year(year_month)
  ) %>%
  dplyr::left_join(population, by = c('year','county')) %>%
  dplyr::select(year, year_month, county, population, type, category_name, state_cost, state_revenue, bottles_sold, volume) %>%
  dplyr::rename(category = category_name)

# Write out data ----
write.csv(liquor_sales, 'csv/liquor_sales.csv', row.names = FALSE)

usethis::use_data(liquor_sales, overwrite = TRUE, compress = 'xz')

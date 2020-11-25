#' Iowa Liquor Sales by County
#' @description Monthly summary of alcohol (class E) sales in Iowa by county
#' @format a data frame with 7 variables
#' 
#' \describe{
#'   \item{year_mon}{Month and year of recorded sale information for the respective county}
#'   \item{county}{Name of county}
#'   \item{county_number}{County number associated with county}
#'   \item{state_cost}{Cost incurred by State of Iowa to purchase liquor from vendor in US dollars (not normalized)}
#'   \item{bottles_sold}{Number of bottles sold for the respective year-month}
#'   \item{retail_revenue}{Sales revenue in US dollars (not normalized)}
#'   \item{liters_sold}{Volume of liquor sold}
#' }
#' 
#' @source State of Iowa Data Portal \href{https://data.iowa.gov/resource/m3tr-qhgy.csv}{website}
"county_sales"

#' Iowa Liquor Sales by Category
#' @description Monthly summary of alcohol (class E) sales in Iowa by alcohol category
#' @format a data frame with 6 variables
#' 
#' \describe{
#'   \item{year_mon}{Month and year of recorded sale information for the respective alcohol category}
#'   \item{category_name}{Name of category of type of alcohol. This field is used to denote multiple brands that fall into the same category.}
#'   \item{state_cost}{Cost incurred by State of Iowa to purchase liquor from vendor in US dollars (not normalized)}
#'   \item{bottles_sold}{Number of bottles sold for the respective year-month}
#'   \item{retail_revenue}{Sales revenue in US dollars (not normalized)}
#'   \item{liters_sold}{Volume of liquor sold}
#' }
#' 
#' @source State of Iowa Data Portal \href{https://data.iowa.gov/resource/m3tr-qhgy.csv}{website}
#' 
"category_sales"
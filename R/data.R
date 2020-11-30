#' Iowa Class E Liquor Sales Summary
#' 
#' @description Monthly summary of the different Class E liquor sales in State of Iowa
#' 
#' @details This dataset contains an aggregated view (aggregated by multiple attributes) of the sales data for Class E liquor. The dataset has been pre-processed to remove NULL values from the county variable. See vignette for more details
#' 
#' @format a data frame with 10 variables.
#' \describe{
#'   \item{year}{The year in which the sale occurred.}
#'   \item{year_month}{This is an aggregated value indicating the month and year in YYYY-MM-DD format.}
#'   \item{county}{The county in which the sale occurred.}
#'   \item{population}{The population of the county of the year of sale as recorded by the US Census Bureau. NA values indicate no census data were found on the Iowa Data Portal.}
#'   \item{type}{A high level grouping of the liquor. This was derived separately.}
#'   \item{category}{A grouping variable used by the State of Iowa.}
#'   \item{state_cost}{The cost (in US$) to the state to purchase the liquor from a vendor. Not adjusted for inflation.}
#'   \item{state_revenue}{The revenue (in US$) the state earned from the sale of the liquor to retailers. Not adjusted for inflation.}
#'   \item{bottles_sold}{The number of bottles sold by the state to a retailer.}
#'   \item{volume}{The volume sold (in liters) by the state to a retailer.}
#' }
#' 
#' @source State of Iowa Data \href{https://data.iowa.gov/resource/m3tr-qhgy.csv}{API}
#' @keywords datasets timeseries liquor revenue
#' 
"liquor_sales"
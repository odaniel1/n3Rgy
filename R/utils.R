#' @title Clean a provided MAC number
#'
#' @description Cleans a user provided MAC number, and checks for errors.
#' @param mac The MAC number (also known as GUID/EUI) of the smart meter of interest.
clean_mac <- function(mac){

  # MAC numbers are often formatted with hyphen separations, but the n3rgy
  # API does not expect these.
  mac <- gsub("-","",mac)

  # Letters in MAC numbers should be upper case
  mac <- toupper(mac)

  # MAC is incorrect length
  if(nchar(mac) != 16 ){
    stop("Invalid MAC number provided: MAC should be 16 letters/digits long")
  }

  # MAC is incorrect length
  if(grepl("[^A-Z0-9]", mac)){
    stop("Invalid MAC number provided: MAC should only include alphanumeric characters")
  }

  return(mac)
}

#' @title Clean a provided date
#'
#' @description Cleans a user provided date, and checks for errors.
#' @param date A date or string purporting to be in %Y-%m-%d format
clean_date <- function(date){
  # confirm provided value is a valid date
  date <- as.Date(date, format = "%Y-%m-%d")

  # cast to character and remove hyphens
  date <- gsub("-", "", date)

  return(date)
}

#' @title Create URL for n3rgy API
#'
#' @description Constructs a valid URL to query to the n3rgy API.
#' @param query_type One of 'consumption' or 'tariff'.
#' @param from (Optional) A date, or string in %Y-%m-%d format representing the earliest date you want data from (n3rgy stores data for 13 months).
#' @param to (Optional) A date, or string in %Y-%m-%d format representing the latest date that you want data until.
create_url <- function(query_type, from = NULL, to = NULL){

  if(!(query_type %in% c("consumption", "tariff"))){
    stop("Argument 'query_type' must be one of 'consumption' or 'tariff")
  }

  url <- paste0("https://consumer-api.data.n3rgy.com/electricity/",query_type,"/1/")

  if(xor(is.null(from), is.null(to))){
    stop("Arguments 'from' and 'to' should either both be provided, or both be skipped.")
  }

  if(!is.null(from)){
    from <- clean_date(from)
    to <- clean_date(to)

    url <- paste0(url, '?start=',from, '&end=', to)
  }

  return(url)
}

#' @title Check API Response Status
#'
#' @description Checks the status of an API response
#' @param resp An API response
check_api_response <- function(resp){
  if(resp$status_code != 200){
    stop(paste0("n3rgy API did not return data: Error ", resp$status_code))
  }
}

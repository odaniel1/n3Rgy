#' @title Get electricity consumption data from n3rgy API
#'
#' @description Returns energy consumption data available from n3rgy.
#' @param mac The MAC number (also known as GUID/EUI) of the smart meter of interest.
#' @param from (Optional) A date, or string in %Y-%m-%d format representing the earliest date you want data from (n3rgy stores data for 13 months).
#' @param to (Optional) A date, or string in %Y-%m-%d format representing the latest date that you want data until.
#' @export
n3rgy_consumption <- function(mac, from = NULL, to = NULL){

  mac <- clean_mac(mac)
  url <- create_url("consumption", from, to)
  resp <- httr::GET(url, httr::add_headers(Authorization=mac))

  check_api_response(resp)

  cont <- jsonlite::fromJSON(
    httr::content(resp,"text",encoding = "UTF-8"),
    simplifyVector = FALSE
  )

  mat <- do.call(rbind, cont$values)

  df <- data.frame(
    timestamp = as.POSIXct(unlist(mat[,1]), format="%Y-%m-%d %H:%M", tz="UTC"),
    value_kWh = unlist(mat[,2])
  )
}

#' @title Get electricity tariff data from n3rgy API
#'
#' @description Returns electricity tariff data available from n3rgy.
#' @param mac The MAC number (also known as GUID/EUI) of the smart meter of interest.
#' @param from (Optional) A date, or string in %Y-%m-%d format representing the earliest date you want data from (n3rgy stores data for 13 months).
#' @param to (Optional) A date, or string in %Y-%m-%d format representing the latest date that you want data until.
#' @export
n3rgy_tariff <- function(mac, from = NULL, to = NULL){

  mac <- clean_mac(mac)
  url <- create_url("tariff", from, to)
  resp <- httr::GET(url, httr::add_headers(Authorization=mac))

  cont <- jsonlite::fromJSON(
    httr::content(resp,"text",encoding = "UTF-8"),
    simplifyVector = FALSE
  )

  check_api_response(resp)

  info <- cont$values[[1]]$additionalInformation
  message(info)

  mat_sc <- do.call(rbind, cont$values[[1]]$standingCharges)
  df_sc <- data.frame(
    timestamp = as.POSIXct(unlist(mat_sc[,1]), format="%Y-%m-%d", tz="UTC"),
    standing_charge_p = unlist(mat_sc[,2])
  )

  mat_p <- do.call(rbind, cont$values[[1]]$prices)
  df_p <- data.frame(
    timestamp = as.POSIXct(unlist(mat_p[,1]), format="%Y-%m-%d %H:%M", tz="UTC"),
    price_per_kWh = unlist(mat_p[,2])
  )

  return(list(standing_charge = df_sc, price_per_kWh = df_p))
}


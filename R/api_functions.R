#' @title Get electricity consumption data from n3rgy API
#'
#' @description Returns energy consumption data available from n3rgy.
#' @param mac The MAC number (also known as GUID/EUI) of the smartmeter of interest.
#' @param from The earliest date you want data from (n3rgy stores data for 13 months).
#' @param to The latest date that you want data until.
#' @export
n3rgy_consumption <- function(mac, from, to){

  mac <- gsub("-","",mac)

  url <- "https://consumer-api.data.n3rgy.com/electricity/consumption/1/"
  qry <- paste0(url, '?start=',from, '&end=', to)

  resp <- httr::GET(qry, httr::add_headers(Authorization=mac))

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
#' @param mac The MAC number (also known as GUID/EUI) of the smartmeter of interest.
#' @param from The earliest date you want data from (n3rgy stores data for 13 months).
#' @param to The latest date that you want data until.
#' @export
n3rgy_tariff <- function(mac, from, to){

  mac <- gsub("-","",mac)

  url <- "https://consumer-api.data.n3rgy.com/electricity/tariff/1/"
  qry <- paste0(url, '?start=',from, '&end=', to)

  resp <- httr::GET(qry, httr::add_headers(Authorization=mac))

  cont <- jsonlite::fromJSON(
    httr::content(resp,"text",encoding = "UTF-8"),
    simplifyVector = FALSE
  )

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


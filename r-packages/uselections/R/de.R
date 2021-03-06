#' @importFrom readr read_csv
#' @import dplyr
#' @export
loadDelaware <- function() {

  countyNameFIPSMapping <- getCountyNameFIPSMapping('10')

  df <- read_csv("data-raw/de/e70r2001_20161201.csv", col_names=paste0('X', seq(5)), col_types='cnnnn') %>%
    select(-X5) %>%
    gather(CountyName, count, X2:X4) %>%
    mutate(X1=ifelse(X1 %in% c('D','R','H','L','I','G'), X1, 'O')) %>%
    group_by(X1, CountyName) %>%
    summarize_each("sum") %>%
    spread(X1, count) %>%
    mutate(CountyName=recode(CountyName, X2="Kent", X3="New Castle", X4="Sussex")) %>%
    mutate_each("as.integer", -CountyName) %>%
    mutate(N=I+G) %>%
    select(-I, -G) %>%
    rename(G=H) %>%
    ungroup() %>%
    inner_join(countyNameFIPSMapping, by=c("CountyName"="CountyName")) %>%
    select(-CountyName) %>%
    mutate(Year = 2016, Month = 11) # Hardcode until we add historical data

  df

}

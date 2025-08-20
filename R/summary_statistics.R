
#' @noRd
prettify_uncertainty <- function(m,lc,uc, digits=2){
  paste0(
    signif(m, digits = digits),
    " (95% UI: ",
    signif(lc, digits = digits),
    " - ",
    signif(uc, digits = digits),
    ")"
  )
}

#' summarise deaths averted
#' @param model_data output of [load_data()]
#' @param digits number of significant digits
#' @return [dplyr::tibble()]
#' @export
summarise_deaths_averted <- function(model_data, digits = 2){
  m <- lc <- uc <- NULL
  `no PSS drug_deaths` <- `PSS drug_deaths` <- deaths_averted <- run <- NULL
  model <- run <- NULL
  model_data |>
    dplyr::mutate(deaths_averted = `no PSS drug_deaths` - `PSS drug_deaths`) |>
    dplyr::group_by(model,run) |>
    dplyr::summarise(deaths_averted = sum(deaths_averted)) |>
    dplyr::group_by(model) |>
    dplyr::summarise(m = stats::median(deaths_averted),
              lc = stats::quantile(deaths_averted,0.025),
              uc = stats::quantile(deaths_averted, 0.975)) |>
    dplyr::mutate(deaths_averted = prettify_uncertainty(m,lc,uc))
}

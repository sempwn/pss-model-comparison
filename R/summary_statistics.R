
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
  model_data |>
    mutate(deaths_averted = `no PSS drug_deaths` - `PSS drug_deaths`) |>
    group_by(model,run) |>
    summarise(deaths_averted = sum(deaths_averted)) |>
    group_by(model) |>
    summarise(m = median(deaths_averted),
              lc = quantile(deaths_averted,0.025),
              uc = quantile(deaths_averted, 0.975)) |>
    mutate(deaths_averted = prettify_uncertainty(m,lc,uc))
}

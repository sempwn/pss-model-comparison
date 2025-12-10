
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
#' @param event Either `"deaths"` or `"overdoses"`. Default is `"deaths"`
#' @param digits number of significant digits
#' @return [dplyr::tibble()]
#' @export
summarise_events_averted <- function(model_data, event = "deaths", digits = 2){
  model <- run <- NULL
  .data <- events_averted <- m <- lc <- uc <- NULL
  col_name <- get_event_cols(event)
  model_data |>
    dplyr::mutate(
      events_averted = .data[[col_name[["counterfactual"]]]] - .data[[col_name[["baseline"]]]]
      ) |>
    dplyr::group_by(model,run) |>
    dplyr::summarise(events_averted = sum(events_averted)) |>
    dplyr::group_by(model) |>
    dplyr::summarise(m = stats::median(events_averted),
              lc = stats::quantile(events_averted,0.025),
              uc = stats::quantile(events_averted, 0.975)) |>
    dplyr::mutate(events_averted = prettify_uncertainty(m,lc,uc, digits = digits))
}

#' @noRd
get_event_cols <- function(event){
  if(event == "deaths"){
    baseline <- "PSS drug_deaths"
    counterfactual <- "no PSS drug_deaths"
  }else if(event == "overdoses"){
    baseline <- "PSS overdoses"
    counterfactual <- "no PSS overdoses"
  }

  list("baseline" = baseline, "counterfactual" = counterfactual)
}
